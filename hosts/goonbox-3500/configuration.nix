{ config, pkgs, ... }:

{
  imports = [
    ../../common
    ../../users/viggokh
    ./hardware-configuration.nix
  ];

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

  users.groups.libvirtd.members = [ "viggokh" ];

  networking.hostName = "goonbox-3500";

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    nvidiaSettings = true;
  };
  hardware.graphics.enable32Bit = true;

  console.keyMap = "dk-latin1";

  services.xserver.layout = "dk";

  programs.sway.package = pkgs.sway.overrideAttrs (old: {
    buildCommand = ''
      ${old.buildCommand}
      wrapProgram $out/bin/sway \
        --add-flags "--unsupported-gpu"
    '';
  });

  programs.virt-manager.enable = true;

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  programs.steam = { 
    extraCompatPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
    remotePlay.openFirewall = true;
  };

  programs.alvr = {
    enable = true;
    openFirewall = true;
  };

  fileSystems."/home/viggokh/storage" = {
    device = "/dev/nvme0n1p3";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  environment.systemPackages = with pkgs; [
    libva
    libva-utils
  ];
}
