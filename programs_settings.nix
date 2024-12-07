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
    config = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core = {
        editor = "nvim";
        whitespace = "trailing-space,space-before-tab";
        autocrlf = "input";
      };
      merge = { conflictstyle = "diff3"; tool = "nvim"; ff = false; };
      diff = {
        colorMoved = "default";
        algorithm = "histogram";
        compactionHeuristic = true;
        mnemonicPrefix = true;
      };
      alias = { b = "branch -vva"; };
      push = {
        default = "current"; # Only push current branch
        followTags = true; # Push tags automatically
      };
      fetch = { prune = true; pruneTags = true; };
      help = { autocorrect = -1; };
    };
  };
}

