{
  config,
  pkgs,
  lib,
  minima,
  inputs,
  ...
}:

{
  imports = [
    ./common.nix
  ];

  home-manager.users.viggokh =
    {
      config,
      pkgs,
      ...
    }:
    {
      services.ssh-agent.enable = true;

      minima = {
        vim = {
          lsp.servers = {
            rust_analyzer = {
              enable = true;
              installCargo = false;
              installRustc = false;
            };
            pyright.enable = true;
            clangd.enable = true;
            qmlls.enable = true;
          };
        };
      };
    };
}
