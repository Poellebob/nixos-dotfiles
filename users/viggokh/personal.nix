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
    ./common.nix
  ];

  age.secrets = {
    searxng-secret = {
      file = ../../secrets/searxng.age;
      owner = "searx";
    };
    cemu-keys = {
      file = ../../secrets/cemu-keys.age;
    };
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

  users.users.viggokh.packages = with pkgs; [
    cemu
    neovide
  ];

  home-manager.users.viggokh =
    {
      config,
      pkgs,
      nixosConfig,
      ...
    }:
    {
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

      home.file.".config/Cemu/keys.txt".source =
        config.lib.file.mkOutOfStoreSymlink nixosConfig.age.secrets.cemu-keys.path;

      programs.zen-browser.profiles.default.search = {
        force = true;
        default = "searxng";
        engines = {
          searxng = {
            name = "SearXNG";
            urls = [ { template = "http://127.0.0.1:8888/search?q={searchTerms}"; } ];
            definedAliases = [ "@s" ];
          };
          google = {
            name = "Google";
            urls = [ { template = "https://www.google.com/search?q={searchTerms}"; } ];
            definedAliases = [ "@g" ];
          };
          github = {
            name = "GitHub";
            urls = [ { template = "https://github.com/search?q={searchTerms}"; } ];
            definedAliases = [ "@gh" ];
          };
          nixpkgs = {
            name = "Nixpkgs";
            urls = [ { template = "https://search.nixos.org/packages?query={searchTerms}"; } ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          mynixos = {
            name = "My NixOS";
            urls = [ { template = "https://mynixos.com/search?q={searchTerms}"; } ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nx" ];
          };
        };
      };

      minima = {
        autostart = [
          "${pkgs.steam}/bin/steam -silent"
        ];
      };
    };
}
