{ config, pkgs, inputs, ... }:
let
  sshkeys = [

  ];
  adminkeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMWCNTxuiA6s9K3FJRWej12dj6v4GsxbtF0qiy41LEY6 viggokh@goonbox-3000"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKWKHcHhycQEuelo+0G6a51NLHY0QiLW/s40xMsxErOx viggokh@framework13"
  ];
in
{
  age = {
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  
    secrets.playit-secret = {
      file = ./secrets/playit-secret.age;
    };
    secrets.cloudflared-token = {
      file = ./secrets/cloudflared-token.age;
    };
    secrets.windrose-env = {
      file = ./secrets/windrose-env.age;
      owner = "root";
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "SlaveUndertheTY";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Copenhagen";

  i18n.defaultLocale = "en_DK.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  services.xserver.xkb = {
    layout = "dk";
    variant = "winkeys";
  };

  console.keyMap = "dk-latin1";

  nix.settings.trusted-users = [ "root" "admin" ];
  users.users.admin = {
    isNormalUser = true;
    description = "admin";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = adminkeys;
  };

  users.users.games = {
    uid = 1001;
    isNormalUser = true;
    description = "minecraft";
    openssh.authorizedKeys.keys = sshkeys ++ adminkeys;
  };

  virtualisation.docker.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
      UseDns = true;
    };
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "74af9739-e7ec-4489-9593-0a14e5351f72" = {
        credentialsFile = "${config.age.secrets.cloudflared-token.path}";
        default = "http_status:404";
      };
    };
  };

  services.playit = {
    enable = true;
    secretPath = config.age.secrets.playit-secret.path;
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [];
  };
  
  systemd.services.minecraft-server = {
    description = "Minecraft Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      Type = "simple";
      User = "games";
      WorkingDirectory = "/home/games/StarT-Eta-2-Hf-1";
      ExecStart = "${pkgs.jdk17_headless}/bin/java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.20.1-47.4.0/unix_args.txt \"$@\"";
      Restart = "on-failure";
      RestartSec = "10s";
      
      NoNewPrivileges = true;
      PrivateTmp = true;
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers.windrose = {
      image = "indifferentbroccoli/windrose-server-docker";
      autoStart = true;
      volumes = [
        "/home/games/windrose/server-files:/home/steam/server-files"
      ];
      environment = {
        PUID = "1001";
        PGID = "100"; # users group
        UPDATE_ON_START = "true";
        SERVER_NAME = "SlaveUndertheTY Windrose";
        MAX_PLAYERS = "10";
      };
      environmentFiles = [
        config.age.secrets.windrose-env.path
      ];
    };
  };
  
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    inputs.agenix.packages."${pkgs.stdenv.hostPlatform.system}".default
    git
    btop
    neovim
    kitty
    mcrcon
    steamcmd
  ];
  
  system.stateVersion = "25.11";
}
