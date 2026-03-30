{ config, pkgs, ... }:

{
  imports = [
    ../../common
    ../../users/viggokh
    ./hardware-configuration.nix
  ];

  networking.hostName = "goonbox-3500";

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    nvidiaSettings = true;
  };
  hardware.graphics.enable32Bit = true;

  programs.sway.package = pkgs.sway.overrideAttrs (old: {
    buildCommand = ''
      ${old.buildCommand}
      wrapProgram $out/bin/sway \
        --add-flags "--unsupported-gpu"
    '';
  });

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
