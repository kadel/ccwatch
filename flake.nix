{
  description = "ccwatch - real-time TUI monitor for Claude Code sessions";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        ccwatch = pkgs.stdenv.mkDerivation {
          pname = "ccwatch";
          version = "0.2.0";

          src = ./cli;

          nativeBuildInputs = [ pkgs.bun ];

          buildPhase = ''
            runHook preBuild

            # No `bun install`: the only dependencies are devDependencies
            # (typescript, @types/node) used for editor/CI type-checking,
            # and `bun build` bundles straight from src without them.
            # Keeping the build network-free is required for sandboxed nix
            # builds (Linux CI) -- a `bun install` here fails there with
            # ConnectionRefused.
            export HOME=$TMPDIR
            bun build --compile --minify src/index.ts --outfile ccwatch

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin
            cp ccwatch $out/bin/ccwatch

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Real-time TUI monitor for Claude Code sessions";
            homepage = "https://github.com/kadel/ccwatch";
            license = licenses.mit;
            mainProgram = "ccwatch";
          };
        };
      in
      {
        packages = {
          default = ccwatch;
          ccwatch = ccwatch;
        };

        apps.default = flake-utils.lib.mkApp {
          drv = ccwatch;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.bun
            pkgs.typescript
          ];
        };
      }
    );
}
