{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";

    steel-flake = {
      url = "github:mattwparas/steel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix-flake = {
      url = "github:mattwparas/helix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs =
    inputs@{
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

          default = helix;
        };
      }
    );
}
