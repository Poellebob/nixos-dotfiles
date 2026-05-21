{ config, pkgs, lib, minima, inputs, ... }:


{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  programs.zsh.enable = true;

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
      opencode
      obsidian
      ungoogled-chromium
      protonvpn-gui
      tor-browser
      qbittorrent
      prismlauncher
      spotify
      discord
      equibop
      obs-studio
    ];
  };

  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = { inherit minima; };
    users.viggokh = {
      home.stateVersion = "25.11";
      imports = [ 
        minima.homeModules.default 
      ];
      minima = {
        enable = true;

        shell.enable = true;
        theming.enable = true;
        enableBranding = true;

        minimaConfig = {
          darkTheme = true;
          wallpaper.engineEnabled = true;
          panel.alwaysVisible = true;
        };

        autostart = [
          "spotify"
          "equibop"
        ];

        specialWorkspaces = {
          discord = {
            key = "m";
            rule = {
              app_id = [
                "discord"
                "WebCord"
                "equibop"
              ];
              class = ["discord"];
            };
          };
          spotify = {
            key = "s";
            rule.class = ["Spotify"];
          };
          obs = {
            key = "o";
            rule.app_id = ["obs-studio"];
          };
          TV = {
            key = "t";
            rule.app_id = ["stremio" ];
            rule.class = ["Stremio"];
          };
        };


        vim = {
          enable = true;

          lsp.servers = {
            rust_analyzer = {
              enable = true;
              installCargo = false;
              installRustc = false;
            };
            pyright.enable = true;
            clangd.enable = true;
            qmlls.enable = true;
            bashls.enable = true;
          };

          lsp.formatter = {
            rust = [ "rustfmt" ];
            python = [ "black" ];
            c = [ "clang-format" ];
            cpp = [ "clang-format" ];
            sh = [ "shfmt" ];
            bash = [ "shfmt" ];
            qml = [ "qmlfmt"  ];
          };

          lsp.formatterOpts = {
            qmlfmt.args = [
              "--width" "80"
              "--indent" "2"
            ];
          };

          plugins = {
          };

          keybinds = [
            { mode = "n"; key = "-p";  action = "<NOP>"; desc = "PlatformIO"; }
            { mode = "n"; key = "-pd"; action = "<cmd>!pio run -t compiledb<CR>"; desc = "Make pio compiledb"; }
            { mode = "n"; key = "-pu"; action = "<cmd>!pio run -t upload<CR>"; desc = "Upload pio project"; }
            { mode = "n"; key = "-pm"; action = "<cmd>!pio run<CR>"; desc = "Make pio project"; }
            { mode = "n"; key = "-pc"; action = "<cmd>!pio run -t clean<CR>"; desc = "Clean pio project"; }
          ];

          autocmd = [
            {
              event = "FileType";
              pattern = [ "rust" "python" ];
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

      home.activation.configureEquibop = inputs.home-manager.lib.hm.dag.entryAfter ["writeBoundary"] ''
        SETTINGS_FILE="$HOME/.config/equibop/settings/settings.json"
        
        mkdir -p "$(dirname "$SETTINGS_FILE")"
        
        if [ -f "$SETTINGS_FILE" ]; then
          ${pkgs.jq}/bin/jq '. + {"enabledThemes": ["midnight.theme.css"]}' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
        else
          echo '{"enabledThemes": ["midnight.theme.css"]}' > "$SETTINGS_FILE"
        fi
      '';
      xdg.configFile."equibop/themes/midnight.theme.css".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/refact0r/midnight-discord/d16c0dd0b403bc0508a22b7ba2048a669a9887ce/themes/midnight.theme.css";
        hash = "sha256-OKHj53x/p0UCtR6bqCXp7G6fnSrgZoKEcg6UVKv0d8I=";
      };
    };
  };
}
