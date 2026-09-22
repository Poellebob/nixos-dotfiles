{
  config,
  pkgs,
  ...
}:
let
  ServerSidedModHash = "a081467fdd8fc497b74faa39efcec39edf167c71";
  serversided = pkgs.fetchPackwizModpack {
    url = "https://raw.githubusercontent.com/SESG-HTX-LAN/server-modpack/${ServerSidedModHash}/pack.toml";
    packHash = "sha256-yjMV6GZ2ZNP2j/v6am4bGpP0jQobGvjhyoRYpNvtuX4=";
  };
in
{
  services.minecraft-servers = {
    enable = true;
    eula = true;

    user = "minecraft";
    group = "minecraft";

    managementSystem.tmux.enable = true;

    servers.andrea = {
      enable = true;
      autoStart = true;
      openFirewall = true;
      enableReload = true;

      jvmOpts = "-Xms2G -Xmx4G";
      serverProperties = {
        server-port = 23343;
        difficulty = "normal";
        gamemode = "survival";
        motd = "Velkommen til the Dreamhouse (for alle goblins og eller Barbi entusiaster)";
        max-players = 20;
        level-name = "world";
      };

      package = pkgs.fabricServers.fabric-26_1_2.override {
        jre_headless = pkgs.openjdk25_headless;
      };

      symlinks = {
        mods = "${serversided}/mods";
      };

      files = {
        config = "${serversided}/config";
        "config/voicechat/voicechat-server.properties" = pkgs.writeTextFile {
          name = "voicechat-server.properties";
          text = ''
            port=24454
            bind_address=
            max_voice_distance=48.0
            whisper_distance=24.0
            codec=VOIP
            mtu_size=1275
            tcp_rate_limit=16
            keep_alive=1000
            enable_groups=true
            voice_host=69.9.185.16:37637
            allow_recording=true
            spectator_interaction=false
            spectator_player_possession=false
            force_voice_chat=false
            login_timeout=10000
            broadcast_range=-1.0
            allow_pings=true
            use_natives=true
            threaded_server_support=false
          '';
        };
        "config/polymer/auto-host.json" = pkgs.writeTextFile {
          name = "auto-host";
          text = builtins.toJSON {
            enabled = true;
            required = true;
            mod_override = true;
            type = "polymer:automatic";

            settings = {
              forced_address = "http://209.25.141.16:42867";
            };

            message = "This server uses resource pack to enhance gameplay with custom textures and models. It might be unplayable without them.";
            disconnect_message = "Couldn't apply server resourcepack!";
            informative_disconnect = true;
            external_resource_packs = [ ];
            setup_early = false;
            resource_pack_status_dialog = true;
            dialog_title = "The server's resource pack is still generating!";
            dialog_default_body = "Waiting...";
            dialog_body_header = "This server requires a resource pack, which hasn't finished generating yet...\nIt might take a while for it to finish!";
            dialog_show_status = true;
            dialog_show_dots = true;
            clear_all_client_resource_packs = false;
            include_hash_in_name = true;
            cache_control_max_age = 31536000;
            delay_player_list_motd_until_generated = false;
          };
        };
      };
    };
  };

  users.users.minecraft = {
    shell = pkgs.bashInteractive;
  };

  systemd.services.minecraft-server-star = {
    enable = true;
    description = "Minecraft Server: Star Tech";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [
      pkgs.bashInteractive
      pkgs.coreutils
      pkgs.tmux
    ];

    serviceConfig = {
      Type = "forking";
      GuessMainPID = true;
      User = "minecraft";
      Group = "minecraft";
      WorkingDirectory = "/srv/minecraft/StarT-Theta-2-Hotfix-1/";

      RuntimeDirectory = "minecraft";
      RuntimeDirectoryPreserve = true;
      RuntimeDirectoryMode = "0770";

      Environment = [
        "SHELL=${pkgs.bashInteractive}/bin/bash"
      ];

      ExecStart = pkgs.writeShellScript "start-star" ''
        sock=/run/minecraft/star.sock
        rm -f "$sock"
        export SHELL="${pkgs.bashInteractive}/bin/bash"
        ${pkgs.tmux}/bin/tmux -S "$sock" set-option -g default-shell "${pkgs.bashInteractive}/bin/bash" \; new-session -d -s mc \
          '${pkgs.jdk17_headless}/bin/java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.20.1-47.4.20/unix_args.txt --nogui'
        ${pkgs.tmux}/bin/tmux -S "$sock" server-access -agw minecraft 2>/dev/null || true
        ${pkgs.tmux}/bin/tmux -S "$sock" server-access -aw admin 2>/dev/null || true
        ${pkgs.coreutils}/bin/chmod 660 "$sock" || true
      '';

      ExecStop = pkgs.writeShellScript "stop-star" ''
        sock=/run/minecraft/star.sock
        server_running() { ${pkgs.tmux}/bin/tmux -S "$sock" has-session 2>/dev/null; }
        if ! server_running; then exit 0; fi
        ${pkgs.tmux}/bin/tmux -S "$sock" send-keys -t mc C-u "stop" Enter
        while server_running; do sleep 1; done
      '';

      TimeoutStopSec = "120s";
      Restart = "on-failure";
      RestartSec = "10s";
      NoNewPrivileges = true;
      PrivateTmp = true;
    };
  };

  systemd.services.minecraft-server-hacker = {
    enable = true;
    description = "Minecraft Server: Hacker man";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [
      pkgs.bashInteractive
      pkgs.coreutils
      pkgs.tmux
    ];

    serviceConfig = {
      Type = "forking";
      GuessMainPID = true;
      User = "minecraft";
      Group = "minecraft";
      WorkingDirectory = "/srv/minecraft/hacker-hytten/";

      RuntimeDirectory = "minecraft";
      RuntimeDirectoryPreserve = true;
      RuntimeDirectoryMode = "0770";

      Environment = [
        "SHELL=${pkgs.bashInteractive}/bin/bash"
      ];

      ExecStart = pkgs.writeShellScript "start-hacker" ''
        sock=/run/minecraft/hacker.sock
        rm -f "$sock"
        export SHELL="${pkgs.bashInteractive}/bin/bash"
        ${pkgs.tmux}/bin/tmux -S "$sock" set-option -g default-shell "${pkgs.bashInteractive}/bin/bash" \; new-session -d -s mc \
          '${pkgs.temurin-bin-17}/bin/java -Xmx10G @libraries/net/minecraftforge/forge/1.20.1-47.4.0/unix_args.txt'
        ${pkgs.tmux}/bin/tmux -S "$sock" server-access -agw minecraft 2>/dev/null || true
        ${pkgs.tmux}/bin/tmux -S "$sock" server-access -aw admin 2>/dev/null || true
        ${pkgs.coreutils}/bin/chmod 660 "$sock" || true
      '';

      ExecStop = pkgs.writeShellScript "stop-hacker" ''
        sock=/run/minecraft/hacker.sock
        server_running() { ${pkgs.tmux}/bin/tmux -S "$sock" has-session 2>/dev/null; }
        if ! server_running; then exit 0; fi
        ${pkgs.tmux}/bin/tmux -S "$sock" send-keys -t mc C-u "stop" Enter
        while server_running; do sleep 1; done
      '';

      TimeoutStopSec = "120s";
      Restart = "on-failure";
      RestartSec = "10s";
      NoNewPrivileges = true;
      PrivateTmp = true;
    };
  };

  environment.systemPackages = [
    pkgs.mcrcon
    (pkgs.writeShellApplication {
      name = "mc-attach";
      runtimeInputs = with pkgs; [
        tmux
        coreutils
        gnused
      ];
      text = ''
        if [ $# -eq 0 ]; then
          echo "Usage: mc-attach <server-name>"
          echo ""
          echo "Available servers:"
          for sock in /run/minecraft/*.sock; do
            [ -e "$sock" ] || continue
            name=$(${pkgs.coreutils}/bin/basename "$sock" .sock)
            echo "  $name -> tmux -S $sock attach"
          done
          exit 1
        fi

        name=$1
        sock="/run/minecraft/$name.sock"

        if [ ! -S "$sock" ]; then
          echo "error: socket $sock not found" >&2
          exit 1
        fi

        exec tmux -S "$sock" attach
      '';
    })
    (pkgs.writeShellApplication {
      name = "mc-console";
      runtimeInputs = [ pkgs.tmux ];
      text = ''
        if [ $# -eq 0 ]; then
          echo "Usage: mc-console <server-name> [command]"
          echo "  Sends a command to the server console without attaching."
          exit 1
        fi

        name=$1
        shift
        sock="/run/minecraft/$name.sock"

        if [ ! -S "$sock" ]; then
          echo "error: socket $sock not found" >&2
          exit 1
        fi

        tmux -S "$sock" send-keys -t mc "$*" Enter
      '';
    })
  ];
}
