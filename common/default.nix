{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.minima.nixosModules.default
  ];

  minima.tex = {
    enable = true;
    scheme = "scheme-full";
    packages = {
      inherit (pkgs.texlive)
        dvisvgm
        dvipng
        wrapfig
        amsmath
        ulem
        hyperref
        capt-of
        enumitem
        float
        starray
        parskip
        booktabs
        xcolor
        listings
        geometry
        plantuml
        ;
    };
    spell = [
      "en"
      "da"
    ];
  };

  nixpkgs.overlays = [
    (final: prev: {
      jackett = prev.jackett.overrideAttrs (old: {
        doCheck = false;
      });
      zen-browser = inputs.zen-browser.packages.${prev.stdenv.hostPlatform.system}.beta.override {
        nativeMessagingHosts = [ pkgs.firefoxpwa-unwrapped ];
      };
    })
    inputs.notsh.overlays.default
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.xserver.enable = true;
  services.displayManager.ly.enable = true;

  security.polkit.enable = true;
  security.rtkit.enable = true;

  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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

  minima = {
    enable = true;
    hyprland = {
      enable = true;
      layout = "hy3";
    };
    keybinds = [
      {
        exec = "${pkgs.kitty}/bin/kitty";
        bind = [ "mainMod" "Return" ];
      }
      {
        exec = "${pkgs.zen-browser}/bin/zen-beta";
        bind = [ "mainMod" "B" ];
      }
      {
        exec = "${pkgs.kdePackages.dolphin}/bin/dolphin";
        bind = [ "mainMod" "E" ];
      }
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  environment.variables.TEXINPUTS = ".:${pkgs.sagetex}/tex/latex/sagetex//:";
  environment.variables.PYTHONPATH = "${
    inputs.sagetex-py.packages.${pkgs.stdenv.hostPlatform.system}.default
  }/lib/python/site-packages";

  fonts = {
    enableDefaultPackages = true;
    fontconfig.enable = true;

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      dbus
    ];
  };

  services.gnome.gnome-keyring.enable = true;

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
    dbus.enable = true;
  };

  programs.steam = {
    enable = true;
    package = pkgs.steam;
  };
  hardware.steam-hardware.enable = true;
  programs.kdeconnect.enable = true;

  environment.systemPackages = with pkgs; [
    # Development
    godotPackages_4_6.godot
    devenv
    gnumake
    git
    ripgrep
    lazygit
    curl
    wget
    jq
    bc
    fzf
    zoxide
    cachix

    packwiz
    dbus

    python313
    gcc.cc.lib
    clang
    libclang
    lua
    luajit
    cargo
    dart-sass

    pyright
    libclang

    platformio
    avrdude

    # LaTeX
    sage
    sagetex
    biber

    # File Management
    gparted
    kdePackages.dolphin
    kdePackages.ark
    kdePackages.kio-gdrive
    kdePackages.kio
    kdePackages.kio-fuse
    kdePackages.kio-admin
    kdePackages.kio-extras
    gvfs
    xdg-utils
    p7zip
    unrar

    # Documents & Office
    libreoffice-fresh
    zathura

    # Media
    mpv
    vlc
    libvlc
    vlc-bittorrent
    f3d
    kdePackages.kdenlive
    kdePackages.gwenview

    # Gaming
    gamemode
    mangohud
    gamescope

    # Desktop
    kitty
    quickshell
    hyprlock
    hypridle
    cliphist
    wl-clipboard
    brightnessctl
    wineWow64Packages.full

    # Qt
    qt5.qtwayland
    qt6.qtwayland

    # Audio
    wireplumber

    # Networking
    networkmanager
    cloudflared
    airtame

    # Bluetooth
    bluez
    bluez-tools
    bluetui

    # Utilities
    notsh
    btop
    fastfetch
    afetch
    polkit
    power-profiles-daemon
    vulkan-tools
    libgtop
    jemalloc
    appimage-run
    firefoxpwa-unwrapped
    zen-browser
    qutebrowser

    # Shell
    zsh

    # Fonts, Themes & Icons
    nerd-fonts.jetbrains-mono
    papirus-icon-theme
    rose-pine-cursor

    # Spell Checking
    hunspell
    hunspellDicts.da_DK
    aspell
    aspellDicts.da

    # Secrets
    inputs.agenix.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];
  system.stateVersion = "26.05";
}
