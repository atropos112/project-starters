{
  inputs,
  pkgs,
  ...
}: let
  pkgu = import inputs.nixpkgs-unstable {system = pkgs.stdenv.system;};
  buildInputs = with pkgu; [
    python3
    poetry
    zlib
  ];
in {
  packages = with pkgu; [
    python3
  ];

  enterShell = ''
    export LD_LIBRARY_PATH="${pkgu.lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH"
    export LD_LIBRARY_PATH="${pkgu.stdenv.cc.cc.lib.outPath}/lib:$LD_LIBRARY_PATH"
  '';
}
