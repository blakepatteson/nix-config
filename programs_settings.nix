{
  programs.bash = {
    enableCompletion = true;
    interactiveShellInit = ''
        PS1='[\D{%Y-%m-%d}] [\t]:\w\$ '
    '';
  };

  programs.chromium = {
    enable = true;
    extraOpts = {
        "crash_reporter.enabled" = false;
        "breakpad.reportURL" = "";
    };
  };

  # Source the Neovim config file
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    configure = {
      customRC = ''
        source /etc/neovim/init.vim
      '';
    };
  };
}