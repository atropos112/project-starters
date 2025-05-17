{
  pkgs,
  lib,
  ...
}: {
  packages = with pkgs; [
    python3
  ];

  env = {
    NIX_LD_LIBRARY_PATH = lib.makeLibraryPath (
      with pkgs; [
        zlib
        libgcc # Pandas, numpy etc.
        stdenv.cc.cc
      ]
    );
    NIX_LD = builtins.readFile "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
  };

  languages.python = {
    enable = true;
    version = "3.13";
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
}
