{ pkgs, lib, ... }:
{
  environment.variables = {
    LESS = "-R -X -F";
    LESSHISTFILE = "-";
    LD_LIBRARY_PATH = lib.mkForce (pkgs.lib.makeLibraryPath [
      pkgs.zlib
      pkgs.expat
      pkgs.minizip
    ]);
    GOTELEMETRY = "off";
    EDITOR = "nvim";
  };
}
