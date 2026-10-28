{
  config,
  pkgs,
  lib,
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
      owner = "viggokh";
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
    ryubing
    tor-browser
    prismlauncher
    vesktop
    spotify
  ];

  home-manager.users.viggokh =
    {
      config,
      pkgs,
      nixosConfig,
      ...
    }:
    {
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
        autostart =
          lib.optional nixosConfig.programs.steam.enable "${nixosConfig.programs.steam.package}/bin/steam -silent"
          ++ [
            "${pkgs.spotify}/bin/spotify --disable-gpu"
            "${pkgs.vesktop}/bin/vesktop --disable-gpu"
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
}
