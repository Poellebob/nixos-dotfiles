{
  description = "nixos configuration";
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
    minima.url = "./minima";
  };
  outputs = { 
    self, 
    nixpkgs, 
    home-manager, 
    dolphin-overlay, 
    minima, 
    ... 
  }@inputs: {
    nixosConfigurations.framework13 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit minima inputs; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          nixpkgs.overlays = [ dolphin-overlay.overlays.default ];
        }
      ];
    };
  };
}
