{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  pkgu = import inputs.nixpkgs-unstable {system = pkgs.stdenv.system;};
  python_pkg = pkgu.python312;

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
  packages = [python_pkg];

  env = {
    NIX_LD_LIBRARY_PATH = lib.makeLibraryPath (with pkgu;
      [
        zlib
        libgcc # Pandas, numpy etc.
        stdenv.cc.cc
      ]
      ++ [python_pkg]);
    NIX_LD = builtins.readFile "${pkgu.stdenv.cc}/nix-support/dynamic-linker";
  };

  enterShell = ''
    ${helpScript}
  '';
}
