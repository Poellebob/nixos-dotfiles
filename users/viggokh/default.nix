{ config, pkgs, lib, minima, inputs, ... }:


{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  programs.zsh.enable = true;
  
  age.secrets.searxng-secret = {
    file = ../../secrets/searxng.age;
    owner = "searx";
  };

  services.searx = {
    enable = true;
    redisCreateLocally = true;
    environmentFile = config.age.secrets.searxng-secret.path;
    settings = {
      server = {
        bind_address = "127.0.0.1";
        port = 8888;
      };
      general = {
        debug = false;
        instance_name = "searx";
      };
      ui = {
        default_theme = "simple";
        theme_args.simple_style = "auto";
      };
    };
  };

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
      obs-studio
      dwarf-fortress-packages.phoebus-theme
      dwarf-fortress 
    ];
  };

  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = { inherit minima; };
    users.viggokh = { config, pkgs, ... }: {
      home.stateVersion = "25.11";
      imports = [ 
        minima.homeModules.default 
        inputs.zen-browser.homeModules.default
      ];

      nixpkgs.config.allowUnfree = true;

      xdg.desktopEntries.dwarf-fortress = {
        name = "Dwarf Fortress";
        comment = "Losing is fun";
        exec = "dwarf-fortress";
        icon = "${pkgs.fetchurl {
          url = "https://cdn2.steamgriddb.com/icon/040ca38cefb1d9226d79c05dd25469cb/32/256x256.png";
          hash = "sha256-LQtGJfgjG81Hp4/TnrqrFns9aNhY0hLEhq5iB6FCKEc=";
        }}";
        categories = [ "Game" ];
        terminal = false;
      };

      programs.zen-browser.profiles.default.search = {
        force = true;
        default = "searxng";
        engines = {
          searxng = {
            name = "SearXNG";
            urls = [{ template = "http://127.0.0.1:8888/search?q={searchTerms}"; }];
            definedAliases = [ "@s" ];
          };
          google = {
            name = "Google";
            urls = [{ template = "https://www.google.com/search?q={searchTerms}"; }];
            definedAliases = [ "@g" ];
          };
          github = {
            name = "GitHub";
            urls = [{ template = "https://github.com/search?q={searchTerms}"; }];
            definedAliases = [ "@gh" ];
          };
          nixpkgs = {
            name = "Nixpkgs";
            urls = [{ template = "https://search.nixos.org/packages?query={searchTerms}"; }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          mynixos = {
            name = "My NixOS";
            urls = [{ template = "https://mynixos.com/search?q={searchTerms}"; }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nx" ];
          };
        };
      };

      minima = {
        enable = true;

        shell.enable = true;
        theming.enable = true;

        minimaConfig = {
          darkTheme = true;
          wallpaper.engineEnabled = true;
          panel.alwaysVisible = true;
        };

        autostart = [
          "${pkgs.spotify}/bin/spotify --disable-gpu"
          "${pkgs.discord}/bin/discord --disable-gpu"
          "steam -silent"
        ];

        specialWorkspaces = {
          discord = {
            key = "m";
            rule = {
              app_id = [
                "discord"
              ];
              class = [
                "discord"
              ];
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
    };
  };
}
