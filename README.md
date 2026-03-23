## Exaple usage

```nix
{
  description = "nixos configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    config.url = "./configuration";
  };
  outputs = { nixpkgs, config, ... }: {
    nixosConfigurations.my-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        config.nixosModules.default
      ];
    };
  };
}
```
