{ config, pkgs, lib, ... }:

{
  imports = [
    ../../common
    ../../users/viggokh
    ./hardware-configuration.nix
  ];

  users.groups.libvirtd.members = [ "viggokh" ];

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

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16 * 1024;
  }];

  programs.virt-manager.enable = true;

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  networking.hostName = "framework13";

  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;

  services.udev.packages = with pkgs; [
    platformio-core.udev
    openocd
  ];

  console.keyMap = "dk-latin1";

  services.xserver.layout = "dk";

  services.displayManager.ly.enable = true;
}
