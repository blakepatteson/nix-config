{ pkgs, lib, ... }:
{
  environment.variables = {
    LESS = "-R -X -F -x4 --quit-if-one-screen --ignore-case --status-column --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs=4 --window=-4";
    LESSHISTFILE = "-";
    LD_LIBRARY_PATH = lib.mkForce (pkgs.lib.makeLibraryPath [
      pkgs.zlib
      pkgs.expat
      pkgs.minizip
    ]);
    GOTELEMETRY = "off";
    EDITOR = "nvim";
    SOUNDFONT = "${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2";
  };
}
