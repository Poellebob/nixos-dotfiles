{
  description = "Viggo Kirkegaard Helstrups nixos configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    dolphin-overlay = {
      url = "github:rumboon/dolphin-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    sagetex-py.url = "github:poellebob/sagetex-py-flake";
    blender-cuda.url = "github:adithyagenie/blender-cuda-nixos";
    minima = {
      url = "git+file:./minima";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, sagetex-py, minima, ... }@inputs:
  {
    nixosConfigurations.goonbox-3500 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        ./hosts/goonbox-3500/configuration.nix
        {
          nix.settings = {
            substituters = [ "https://adithyagenie.cachix.org" ];
            trusted-public-keys = [ "adithyagenie.cachix.org-1:h6BSMboeVfxyrULWuRQqAyweo4AJRATekb88xotfQwc=" ];
          };
        }
      ];
      specialArgs = { inherit minima inputs; };
    };

    nixosConfigurations.framework13 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        ./hosts/framework13/configuration.nix
      ];
      specialArgs = { inherit minima inputs; };
    };
  };
}
