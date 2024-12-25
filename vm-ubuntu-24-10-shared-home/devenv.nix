{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  pkgu = import inputs.nixpkgs-unstable {system = pkgs.stdenv.system;};
  lima_yaml = ./lima.yaml;
in {
  packages = [
    pkgu.lima
  ];

  scripts = {
    setup-vm = {
      description = "Setup a Lima VM";
      exec = ''
        if [ -z "$1" ]; then
          echo "Usage: $0 <name>"
          exit 1
        fi
        export LIMA_SHELL=/bin/zsh

        limactl start --name=$1 ${lima_yaml}
      '';
    };
    start-vm = {
      description = "Start a Lima VM";
      exec = ''
        if [ -z "$1" ]; then
          echo "Usage: $0 <name>"
          exit 1
        fi
        export LIMA_SHELL=/bin/zsh

        limactl shell $1
      '';
    };
    remove-vm = {
      description = "Remove a Lima VM";
      exec = ''
        if [ -z "$1" ]; then
          echo "Usage: $0 <name>"
          exit 1
        fi

        limactl stop $1 && limactl remove $1
      '';
    };
  };

  enterShell = ''

    # Scripts message
    echo
    echo 🦾 Useful project scripts:
    echo 🦾
    ${pkgs.gnused}/bin/sed -e 's| |••|g' -e 's|=| |' <<EOF | ${pkgs.util-linuxMinimal}/bin/column -t | ${pkgs.gnused}/bin/sed -e 's|^|🦾 |' -e 's|••| |g'
    ${lib.generators.toKeyValue {} (lib.mapAttrs (_: value: value.description) config.scripts)}
    EOF
    echo
  '';
}
