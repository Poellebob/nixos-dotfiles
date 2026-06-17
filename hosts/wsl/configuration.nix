{ config, pkgs, inputs, minima, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  wsl = {
    enable = true;
    defaultUser = "viggokh";
    startMenuLaunchers = true;
    wslConf.automount.options = "metadata,uid=1000,gid=100";
  };

  networking.hostName = "wsl";
  networking.networkmanager.enable = true;

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config.allowUnfree = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

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

  nix.settings.trusted-users = [ "viggokh" ];

  users.users.viggokh = {
    isNormalUser = true;
    description = "Viggo Kirkegaard Helstrup";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    neovim
    curl
    wget
    ripgrep
    lazygit
    btop
    fastfetch
    jq
    inputs.agenix.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];

  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = { inherit minima inputs; nixosConfig = config; };
    users.viggokh = { config, pkgs, lib, ... }: {
      home.stateVersion = "26.05";
      imports = [ minima.homeModules.default ];

      minima = {
        enable = true;
        shell.enable = true;
        theming.enable = false;
        desktop = {
          enable = false;
          xdgPortal = false;
        };
      };
    };
  };

  system.stateVersion = "26.05";
}
