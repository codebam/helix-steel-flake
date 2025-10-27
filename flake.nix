{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";

    steel-flake = {
      url = "github:mattwparas/steel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix-flake = {
      url = "github:mattwparas/helix/steel-event-system";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      steel-flake,
      helix-flake,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = rec {
          helix = helix-flake.packages.${system}.helix;
          steel = steel-flake.packages.${system}.steel;

          helix-scheme =
            {
              config ? { },
            }:
            let
              tomlFormat = pkgs.formats.toml { };
              configFile = tomlFormat.generate "config.toml" config;
            in
            pkgs.stdenv.mkDerivation {
              name = "helix-scheme";
              src = ./.;
              phases = [ "installPhase" ];

              nativeBuildInputs =
                with pkgs;
                [
                  makeWrapper
                ]
                ++ [
                  steel
                ];

              installPhase = ''
                mkdir -p $out/bin
                mkdir -p $out/lib

                cp ${pkgs.lib.getExe helix} $out/bin/hxs
                wrapProgram $out/bin/hxs \
                  --add-flags "-c ${configFile}" \
                  --set HELIX_STEEL_CONFIG "$out/lib" \

                install -m0755 $src/helix.scm $out/lib/
                install -m0755 $src/init.scm $out/lib/
              '';
            };

          default = helix-scheme { };
        };
      }
    );
}
