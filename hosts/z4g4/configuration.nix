{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ../../common
    ../../users/viggokh/work.nix
    ./hardware-configuration.nix
  ];

  minima = {
    enable = true;
    enableNvidia = true;
    displays = {
      DP-3 = {
        res = "2560x1440";
        position = {
          x = 0;
          y = 0;
        };
        scale = 1.333333;
        primary = true;
      };
    };
  };

  age = {
    identityPaths = [ "/home/viggokh/.ssh/id_ed25519" ];
  };

  users.groups.libvirtd.members = [ "viggokh" ];

  boot = {
    initrd.luks.devices."luks-c7afffcb-6f2f-4bd7-bdda-83283edd7d59".device =
      "/dev/disk/by-uuid/c7afffcb-6f2f-4bd7-bdda-83283edd7d59";
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

    kernelPackages = pkgs.linuxPackages_latest;

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

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  programs.virt-manager.enable = true;

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  networking.hostName = "Workstasion_Z4_G4";

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.bluetooth.enable = true;
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
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

  console.keyMap = "dk-latin1";

  services.xserver.layout = "dk";

  services.displayManager.ly.enable = true;

  environment.systemPackages = with pkgs; [
    swtpm
  ];
}
