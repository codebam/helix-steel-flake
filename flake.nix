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

          helix-steel =
            { }:
            pkgs.stdenv.mkDerivation {
              name = "hx";
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

                cp ${pkgs.lib.getExe helix} $out/bin/hx
              '';
            };

          default = helix-steel { };
        };
      }
    );
}
