{ ... }:
{
  programs.bash = {
    interactiveShellInit = ''
      PS1='[\D{%Y-%m-%d}] [\t]:\w\$ '
      eval "$(direnv hook bash)"
    '';
    enableCompletion = true;
  };

  programs.chromium = {
    enable = true;
    extraOpts = { "crash_reporter.enabled" = false; "breakpad.reportURL" = ""; };
  };

  programs.direnv.enable = true;

  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        whitespace = "trailing-space,space-before-tab";
        autocrlf = "input";
      };
      merge = { conflictstyle = "diff3"; tool = "nvim"; };
      diff = {
        colorMoved = "default";
        algorithm = "histogram";
        compactionHeuristic = true;
        mnemonicPrefix = true;
      };
      alias = { b = "branch -vva"; };
      fetch = { prune = true; prunetags = true; };
      push = { default = "current"; followTags = true; };
      help = { autocorrect = -1; };
      pull = { ff = "only"; rebase = false; };
      advice.addIgnoredFile = false;
      url = { "ssh://git@github.com/".insteadOf = "https://github.com/"; };
    };
  };
}

