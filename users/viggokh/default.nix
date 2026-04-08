{ config, pkgs, lib, minima, inputs, ... }:

let 
  zen-browser = inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

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
      discord
      obs-studio
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

        shell.enable   = true;
        theming.enable = true;
        enableBranding = true;

        terminal = {
          name    = "kitty";
          package = pkgs.kitty;
        };

        minimaConfig = {
          darkTheme = true;
          wallpaper.engineEnabled = false;
          panel.alwaysVisible     = true;
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
}
