# Welcome to my personel nixos config.

This flake has every thing configrured that i use on multiple mashines.

Mashine spesefic conigs are in orthan braches importing the *master* brach.

## Usage:

Fork this repo and clone it into a dir in your os config folder, import like this.

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
