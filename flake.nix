{
  description = "Viggo Kirkegaard Helstrups nixos configuration";

  nixConfig = {
    extra-substituters = [ "https://playit-nixos-module.cachix.org" ];
    extra-trusted-public-keys = [
      "playit-nixos-module.cachix.org-1:22hBXWXBbd/7o1cOnh+p0hpFUVk9lPdRLX3p5YSfRz4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # pterodactyl = {
    #   url = "git+https://codeberg.org/Poellebob/pterodactyl-flake.git";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    notsh = {
      url = "git+https://codeberg.org/Poellebob/notsh.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    playit = {
      url = "github:pedorich-n/playit-nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    millennium = {
      url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
      url = "github:Poellebob/minima-shell/devel/master";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      millennium,
      sagetex-py,
      playit,
      agenix,
      minima,
      nixos-wsl,
      ...
    }@inputs:
    {
      nixosConfigurations.goonbox-3500 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          agenix.nixosModules.default
          playit.nixosModules.default
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
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          ./hosts/framework13/configuration.nix
        ];
        specialArgs = { inherit minima inputs; };
      };

      nixosConfigurations.homeserver = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          agenix.nixosModules.default
          playit.nixosModules.default
          ./hosts/homeserver/configuration.nix
        ];
        specialArgs = { inherit inputs; };
      };

      nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          home-manager.nixosModules.home-manager
          ./hosts/wsl/configuration.nix
        ];
        specialArgs = { inherit minima inputs; };
      };
    };
}
