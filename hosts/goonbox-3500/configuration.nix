{ config, pkgs, lib, inputs, ... }:

let
  wivrnpkg = (pkgs.wivrn.override { cudaSupport = true; });
  wayvr-wrapped = pkgs.symlinkJoin {
    name = "wayvr-wrapped";
    paths = [ pkgs.wayvr ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/wayvr \
        --run 'export PRESSURE_VESSEL_FILESYSTEMS_RW="$XDG_RUNTIME_DIR/wivrn/comp_ipc"' \
        --set PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES 1
    '';
  };
in
{
  imports = [
    ../../common
    ../../users/viggokh
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  minima = {
    enableNvidia = true;
    displays = {
      DP-1 = {
        res      = "1920x1080";
        position = { x = 0; y = 0; };
        scale    = 1.0;
        workspace = 1;
      };
      HDMI-A-1 = {
        res      = "1920x1080";
        position = { x = -1920; y = 0; };
        scale    = 1.0;
        workspace = 10;
      };
    };
  };

  boot = {
    loader = {
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
      efi.canTouchEfiVariables = true;
    };

    consoleLogLevel = 3;

    initrd = {
      verbose = false;
      systemd.enable = true;
    };

    kernelPackages = pkgs.linuxPackages;

    kernelParams = [
      "quiet"
      "splash"
      "intremap=on"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
      "zswap.enabled=1"
      "zswap.compressor=lz4"
      "zswap.max_pool_percent=20"
      "zswap.shrinker_enabled=1"
    ];

    plymouth = {
      enable = true;
      font = "${pkgs.hack-font}/share/fonts/truetype/Hack-Regular.ttf";
      logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake.png";
    };
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16 * 1024;
  }];

  users.groups.libvirtd.members = [ "viggokh" ];
  users.extraGroups.docker.members = [ "viggokh" ];

  networking.hostName = "goonbox-3500";

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
  };
  hardware.graphics = { 
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      cudaPackages.cudatoolkit
      nvidia-vaapi-driver
      libva
    ];
  };

  hardware.bluetooth.enable = true;

  console.keyMap = "dk-latin1";

  services.xserver.layout = "dk";

  programs.virt-manager.enable = true;

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    docker.enable = true;
  };
  
  services.xserver.windowManager.i3.enable = true;
  programs.steam = { 
    extraCompatPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
    remotePlay.openFirewall = true;
    package = lib.mkDefault (
      pkgs.steam.override (prev: {
        extraEnv =
        {
          QT_QPA_PLATFORM = "xcb";
          PRESSURE_VESSEL_FILESYSTEMS_RW = "$XDG_RUNTIME_DIR/wivrn/comp_ipc";
          PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES = 1;
        }
        // (prev.extraEnv or {});
      })
    );
  };
  environment.sessionVariables.LIBVA_DRIVER_NAME = "nvidia";
  home-manager.users.viggokh = { config, pkgs, ... }: {
    xdg.configFile."openxr/1/active_runtime.json" = {
      source = "${wivrnpkg}/share/openxr/1/openxr_wivrn.json";
      force = true;
    };

    xdg.configFile."openvr/openvrpaths.vrpath" = {
      text = ''
        {
          "config" : [
            "${config.xdg.dataHome}/Steam/config"
          ],
          "external_drivers" : null,
          "jsonid" : "vrpathreg",
          "log" : [
            "${config.xdg.dataHome}/Steam/logs"
          ],
          "runtime" : [
            "${pkgs.opencomposite}/lib/opencomposite"
          ],
          "version" : 1
        }
      '';
      force = true;
    };
  };

  # hlvr:  DRI_PRIME=1 GDK_BACKEND=wayland SDL_VIDEODRIVER=wayland CLUTTER_BACKEND=wayland LIBVA_DRIVER_NAME=nvidia GBM_BACKEND=nvidia-drm __GLX_VENDOR_LIBRARY_NAME=nvidia QT_QPA_PLATFORM=xcb PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/wivrn/comp_ipc PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1 %command% -console -vconsole +vr_fidelity_level_auto 0 +vr_fidelity_level 3


  services.wivrn = {
    enable = true;
    openFirewall = true;
    steam = {
      importOXRRuntimes = true;
      package = config.programs.steam.package;
    };
    defaultRuntime = true;
    autoStart = true;
    package = wivrnpkg;
  };

  fileSystems."/home/viggokh/storage" = {
    device = "/dev/nvme0n1p3";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  environment.systemPackages = with pkgs; [
    inputs.blender-cuda.packages.${pkgs.stdenv.hostPlatform.system}.blender-with-cuda
    nvidia-vaapi-driver
    wayvr-wrapped
    libva
    libva-utils
    android-tools
    wlx-overlay-s
    opencomposite
    winboat
    docker-compose
    podman
    podman-compose
    freerdp
  ];
}
