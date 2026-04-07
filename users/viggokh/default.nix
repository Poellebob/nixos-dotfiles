{ config, pkgs, lib, minima, inputs, ... }:

let 
  zen-browser = inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  users.groups.libvirtd.members = [ "viggokh" ];
 
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
      zen-browser
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
    ];
  };

  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = { inherit minima; };
    users.viggokh = {
      home.stateVersion = "25.11";
      imports = [ 
        minima.homeModules.default 
        inputs.zen-browser.homeModules.beta
      ];
      minima = {
        enable = true;
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

          lsp.conform = {
            rust = [ "rustfmt" ];
            python = [ "black" ];
            c = [ "clang-format" ];
            cpp = [ "clang-format" ];
            qml = [ "trim_whitespace" ];
            sh = [ "shfmt" ];
            bash = [ "shfmt" ];
            tex = [ "latexindent" ];
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

  services = {
    printing.enable = true;
    flatpak.enable = true;
    upower.enable = true;
    fwupd.enable = true;
  };

  services.udev.packages = with pkgs; [
    platformio-core.udev
    openocd
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  environment.variables.TEXINPUTS =
    ".:${pkgs.sagetex}/tex/latex/sagetex//:";

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [];
  };

  fonts = {
    enableDefaultPackages = true;
    fontconfig.enable = true;

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
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
    kdePackages.gwenview
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
    mpv
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
