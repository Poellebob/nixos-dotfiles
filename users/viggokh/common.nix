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
      vscodium
      zed-editor
      obsidian
      ungoogled-chromium
      proton-vpn
      tor-browser
      qbittorrent
      prismlauncher
      spotify
      vesktop
      obs-studio
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
            obs = {
              keybind = [
                "Main"
                "o"
              ];
              rule.app_id = [ "obs-studio" ];
            };
          };

          vim = {
            enable = true;

            lsp.servers = {
              bashls.enable = true;
            };

            autocmd = [
              {
                event = "FileType";
                pattern = [
                  "rust"
                  "python"
                ];
                command = "setlocal tabstop=4 shiftwidth=4 softtabstop=4";
                desc = "4-space indent for rust and python";
              }
              {
                event = "FileType";
                pattern = "tex";
                command = "setlocal spell spelllang=da,en";
                desc = "Danish/English spell checking for LaTeX";
              }
            ];
          };
        };
      };
  };
}
