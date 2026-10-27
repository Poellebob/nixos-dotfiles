{
  config,
  pkgs,
  lib,
  minima,
  inputs,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  nixpkgs = {
    overlays = [
      (final: prev: {
        qutebrowser = prev.qutebrowser.override { enableWideVine = true; };
      })
    ];
    config = {
      permittedInsecurePackages = [
        "electron-40.10.5"
      ];
    };
  };

  programs.zsh.enable = true;

  nix.settings.trusted-users = [ "viggokh" ];

  users.users.viggokh = {
    isNormalUser = true;
    description = "Viggo Kirkegaard Helstrup";
    extraGroups = [
      "libvirtd"
      "networkmanager"
      "wheel"
      "uucp"
      "dialout"
    ];
    shell = pkgs.zsh;

    packages = with pkgs; [
      thunderbird
      neovide
      vscodium
      zed-editor
      obsidian
      ungoogled-chromium
      proton-vpn
      qbittorrent
    ];
  };

  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = {
      inherit minima inputs;
      nixosConfig = config;
    };
    users.viggokh =
      {
        config,
        pkgs,
        nixosConfig,
        ...
      }:
      {
        home.stateVersion = "26.05";
        imports = [
          minima.homeModules.default
          inputs.zen-browser.homeModules.default
        ];

        home.sessionVariables = {
          EDITOR = "nvim";
        };
        home.shellAliases = {
          oc = "opencode";
        };

        programs.tmux = {
          enable = true;
          shell = "${pkgs.zsh}/bin/zsh";
          clock24 = true;
          mouse = true;
        };

        nixpkgs.config.allowUnfree = true;

        xdg.mimeApps.defaultApplications = { };

        programs.opencode = {
          enable = true;
          agents = {
            chat = ./opencode/chat.md;
          };
        };

        minima = {
          enable = true;

          shell.enable = true;
          theming.enable = true;

          darkTheme = true;
          wallpaper.engineEnabled = true;
          panel.alwaysVisible = true;

          autostart = [
            "${pkgs.spotify}/bin/spotify --disable-gpu"
            "${pkgs.vesktop}/bin/vesktop --disable-gpu"
            "${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnectd"
          ];

          specialWorkspaces = {
            discord = {
              keybind = [
                "Main"
                "m"
              ];
              rule = {
                app_id = [
                  "discord"
                  "vesktop"
                ];
                class = [
                  "discord"
                  "vesktop"
                ];
              };
            };
            spotify = {
              keybind = [
                "Main"
                "s"
              ];
              rule.class = [ "Spotify" ];
            };
          };
        };
      };
  };
}
