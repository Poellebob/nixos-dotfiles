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
    minima.url = "github:Poellebob/minima-shell/devil";
  };
  outputs = { home-manager, dolphin-overlay, minima, ... }@inputs: {
    nixosModules.default = { ... }: {
      imports = [
        home-manager.nixosModules.home-manager
        ./configuration.nix
      ];
      nixpkgs.overlays = [ dolphin-overlay.overlays.default ];
      _module.args = { inherit minima inputs; };
    };
  };
}
