{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  pkgu = import inputs.nixpkgs-unstable {system = pkgs.stdenv.system;};

  helpScript = ''
    echo
    echo 🦾 Useful project scripts:
    echo 🦾
    ${pkgs.gnused}/bin/sed -e 's| |••|g' -e 's|=| |' <<EOF | ${pkgs.util-linuxMinimal}/bin/column -t | ${pkgs.gnused}/bin/sed -e 's|^|🦾 |' -e 's|••| |g'
    ${lib.generators.toKeyValue {} (lib.mapAttrs (_: value: value.description) config.scripts)}
    EOF
    echo
  '';
in {
  packages = [pkgu.python312];

  env = {
    NIX_LD_LIBRARY_PATH = lib.makeLibraryPath (
      with pkgu; [
        zlib
        libgcc # Pandas, numpy etc.
        stdenv.cc.cc
      ]
    );
    NIX_LD = builtins.readFile "${pkgu.stdenv.cc}/nix-support/dynamic-linker";
  };

  languages.python = {
    enable = true;
    version = "3.12"; # Have to use that so the libraries work
    libraries = with pkgs; [
      zlib
      libgcc # Pandas, numpy etc.
      stdenv.cc.cc
    ];
    uv = {
      enable = true;
      package = pkgs.uv;
      sync = {
        enable = true;
        allExtras = true;
      };
    };
    venv = {
      enable = true;
    };
  };

  enterShell = ''
    ${helpScript}
  '';
}
