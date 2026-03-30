{
  description = "Viggo Kirkegaard Helstrups nixos configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    dolphin-overlay.url = "github:rumboon/dolphin-overlay";
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
    minima = {
      url = "git+file:./minima";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, dolphin-overlay, minima, ... }@inputs:
let
  goonboxConfig = import "${self}/hosts/goonbox-3500/configuration.nix";
  frameworkConfig = import "${self}/hosts/framework13/configuration.nix";
in
{
    nixosConfigurations.goonbox-3500 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        goonboxConfig
      ];
      specialArgs = { inherit minima inputs; };
    };

    nixosConfigurations.framework13 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        frameworkConfig
      ];
      specialArgs = { inherit minima inputs; };
    };
  };
}
