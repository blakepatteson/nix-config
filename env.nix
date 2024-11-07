{ pkgs, ... }:

{
  environment.variables = {
    LESS = "-R -X -F";
    LESSHISTFILE = "-"; # Disable .lesshst file
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.zlib
      pkgs.expat
      pkgs.minizip
    ];
    GOTELEMETRY = "off";
    EDITOR = "nvim";
  };
}
