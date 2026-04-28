{ config, pkgs, lib, inputs, ... }:

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
    ;};
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
    })
    inputs.dolphin-overlay.overlays.default
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
    wm       = "sway";
    modifier = "Mod4";

    programs = {
      fileManager = {
        name = "dolphin";
        package = pkgs.kdePackages.dolphin;
      };
      browser = {
        name = "zen-beta";
        package = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
          nativeMessagingHosts = [pkgs.firefoxpwa];
        };
      };
    };

    autostart = [
      "spotify"
      "discord"
    ];

    specialWorkspaces = {
      discord = {
        key = "m";
        rule = {
          app_id = [
            "discord"
            "WebCord"
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
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  environment.variables.TEXINPUTS =
    ".:${pkgs.sagetex}/tex/latex/sagetex//:";
  environment.variables.PYTHONPATH = 
    "${inputs.sagetex-py.packages.${pkgs.stdenv.hostPlatform.system}.default}/lib/python/site-packages";

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

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraArgs = "-console";
    };
  };
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
    sagetex
    git
    ripgrep
    lazygit
    wget
    curl
    p7zip
    cloudflared
    bluetui
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
    cachix
    zsh
    fastfetch
    afetch
    polkit
    matugen
    papirus-icon-theme
    rose-pine-cursor
    xdg-utils
    cargo
    mpv
    vlc
    libvlc
    vlc-bittorrent
  ];

  system.stateVersion = "25.11";
}
