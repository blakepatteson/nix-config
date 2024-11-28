{
  programs.bash = {
    enableCompletion = true;
    interactiveShellInit = '' PS1='[\D{%Y-%m-%d}] [\t]:\w\$ ' '';
  };

  programs.chromium = {
    enable = true;
    extraOpts = { "crash_reporter.enabled" = false; "breakpad.reportURL" = ""; };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    config = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core = { editor = "nvim"; pager = "delta"; };
      interactive = { diffFilter = "delta --color-only"; };
      delta = {
        enable = true;
        options = {
          features = "decorations";
          navigate = true;
          light = false;
          side-by-side = true;
          line-numbers = true;
        };
      };
      merge = { conflictstyle = "diff3"; };
      diff = { colorMoved = "default"; };
    };
  };
}

