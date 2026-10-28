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
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
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
      nixpkgs-unstable,
      home-manager,
      millennium,
      sagetex-py,
      playit,
      agenix,
      minima,
      nixos-wsl,
      nix-minecraft,
      ...
    }@inputs:
    let
      devenvUnstableOverlay = final: prev: {
        devenv = nixpkgs-unstable.legacyPackages.${prev.system}.devenv;
      };
    in
    {
      nixosConfigurations.goonbox-3500 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          agenix.nixosModules.default
          playit.nixosModules.default
          home-manager.nixosModules.home-manager
          ./hosts/goonbox-3500/configuration.nix
          {
            nixpkgs.overlays = [
              devenvUnstableOverlay
              inputs.nix-cachyos-kernel.overlays.pinned
            ];

            nix.settings = {
              substituters = [
                "https://cache.nixos.org"
                "https://adithyagenie.cachix.org"
                "https://cache.lantian.pub/lantian"
              ];

              trusted-public-keys = [
                "adithyagenie.cachix.org-1:h6BSMboeVfxyrULWuRQqAyweo4AJRATekb88xotfQwc="
                "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
              ];
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
          { nixpkgs.overlays = [ devenvUnstableOverlay ]; }
        ];
        specialArgs = { inherit minima inputs; };
      };

      nixosConfigurations.z4g4 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          ./hosts/z4g4/configuration.nix
          { nixpkgs.overlays = [ devenvUnstableOverlay ]; }
        ];
        specialArgs = { inherit minima inputs; };
      };

      nixosConfigurations.homeserver = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          agenix.nixosModules.default
          playit.nixosModules.default
          nix-minecraft.nixosModules.minecraft-servers
          {
            nixpkgs.overlays = [ nix-minecraft.overlays.default ];
          }
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
          { nixpkgs.overlays = [ devenvUnstableOverlay ]; }
        ];
        specialArgs = { inherit minima inputs; };
      };
    };
}
