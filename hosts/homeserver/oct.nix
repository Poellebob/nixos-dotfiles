{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.oct-server;
in
{
  options.services.oct-server = {
    enable = mkEnableOption "Open Collaboration Tools (OCT) server";

    image = mkOption {
      type = types.str;
      default = "ghcr.io/eclipse-oct/open-collaboration-tools/oct-server-dev:latest";
      description = "Container image to run.";
    };

    port = mkOption {
      type = types.port;
      default = 8100;
      description = "Host port to expose the OCT server on.";
    };

    simpleLogin = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable OCT's simple (username-only, no OAuth) login.
        Corresponds to OCT_ACTIVATE_SIMPLE_LOGIN in the upstream image.
      '';
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Optional file with extra environment variables (e.g. OAuth client
        secrets), in the format expected by systemd's EnvironmentFile=
        (KEY=VALUE per line). Passed to the container as --env-file.
      '';
    };

    extraEnvironment = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Extra environment variables to pass to the container.";
      example = {
        OCT_LOG_LEVEL = "debug";
      };
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/oct-server";
      description = "Directory on the host used for persistent container state.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open the configured port in the firewall.";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0750 root root - -"
    ];

    virtualisation.oci-containers.containers.oct-server-dev = {
      image = cfg.image;
      autoStart = true;
      ports = [ "${toString cfg.port}:8100" ];
      environment = cfg.extraEnvironment // {
        OCT_ACTIVATE_SIMPLE_LOGIN = if cfg.simpleLogin then "true" else "false";
      };
      environmentFiles = optional (cfg.environmentFile != null) cfg.environmentFile;
      volumes = [
        "${cfg.dataDir}:/data"
      ];
      extraOptions = [
        "--pull=always"
      ];
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
  };
}
