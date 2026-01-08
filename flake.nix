{
  description = "Thorium Browser Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      packages.${system} = rec {
        thorium = pkgs.callPackage ./thorium.nix { };
        default = thorium;
      };

      apps.${system} = rec {
        thorium = {
          type = "app";
          program = "${self.packages.${system}.thorium}/bin/thorium-browser";
        };
        default = thorium;
      };
    };
}
