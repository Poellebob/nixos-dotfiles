{ config, pkgs, lib, inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      jackett = prev.jackett.overrideAttrs (old: {
        doCheck = false;
      });
    })
    inputs.dolphin-overlay.overlays.default
  ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  
  services.xserver.enable = true;
  services.displayManager.ly.enable = true;

  programs = {
    zsh.enable = true;
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [];
    };
  };

  security.polkit.enable = true;
  security.rtkit.enable = true;

  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.graphics = { 
    enable = true;
    enable32Bit = true;
  };
  hardware.bluetooth.enable = true;

  services.jackett = {
    enable = true;
    openFirewall = true;
    port = 9117;
  };

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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  environment.variables.TEXINPUTS =
    ".:${pkgs.sagetex}/tex/latex/sagetex//:";

  fonts = {
    enableDefaultPackages = true;
    fontconfig.enable = true;

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };
  
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [];
  };

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  services = {
    printing.enable = true;
    flatpak.enable = true;
    upower.enable = true;
    fwupd.enable = true;
  };

  programs.steam.enable = true;
  programs.kdeconnect.enable = true;

  environment.systemPackages = with pkgs; [
    hunspell
    hunspellDicts.da_DK
    aspell
    aspellDicts.da
    appimage-run
    vim
    biber
    zathura
    gnumake
    pyright
    libclang
    platformio
    avrdude
    airtame
    firefoxpwa
    lua
    luajit
    libreoffice-fresh
    sage
    git
    ripgrep
    lazygit
    wget
    curl
    p7zip
    cloudflared
    bluetui
    kdePackages.dolphin
    kdePackages.ark
    kdePackages.discover
    kdePackages.breeze
    kdePackages.breeze-gtk
    kdePackages.kio
    kdePackages.kio-fuse
    kdePackages.kio-extras
    kdePackages.qtdeclarative
    quickshell
    wireplumber
    vulkan-tools
    libgtop
    bluez
    bluez-tools
    btop
    networkmanager
    jemalloc
    dart-sass
    wl-clipboard
    brightnessctl
    swww
    python3
    power-profiles-daemon
    gvfs
    cliphist
    hyprlock
    hypridle
    kitty
    qt5.qtwayland
    qt6.qtwayland
    nerd-fonts.jetbrains-mono
    grim
    slurp
    swappy
    jq
    bc
    fzf
    zoxide
    zsh
    fastfetch
    afetch
    polkit
    matugen
    papirus-icon-theme
    rose-pine-cursor
    xdg-utils
    cargo
  ];

  system.stateVersion = "25.11";
}
