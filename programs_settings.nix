{
  programs.bash = {
    enableCompletion = true;
    interactiveShellInit = '' PS1='[\D{%Y-%m-%d}] [\t]:\w\$ ' '';
  };

  programs.chromium = {
    enable = true;
    extraOpts = { "crash_reporter.enabled" = false; "breakpad.reportURL" = ""; };
  };
}

