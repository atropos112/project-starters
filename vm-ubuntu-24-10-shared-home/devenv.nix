{
  inputs,
  pkgs,
  config,
  ...
}: let
  inherit (inputs.atrolib.lib) listScripts writeShellScript;
  inherit (inputs.atrolib.lib.devenv.scripts) help;
  lima_yaml = ./lima.yaml;
in {
  packages = with pkgs; [
    lima
  ];

  scripts = {
    help = help config.scripts;
    setup-vm = {
      description = "Setup a Lima VM";
      exec = writeShellScript "setup-vm" ''
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
      exec = writeShellScript "start-vm" ''
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
      exec = writeShellScript "remove-vm" ''
        if [ -z "$1" ]; then
          echo "Usage: $0 <name>"
          exit 1
        fi

        limactl stop $1 && limactl remove $1
      '';
    };
  };

  enterShell = listScripts config.scripts;
}
