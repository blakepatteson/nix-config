{ ... }:
{
  programs.bash = {
    completion.enable = true;
    interactiveShellInit = /* bash */ ''
      PS1='[\D{%Y-%m-%d}] [\t]:\w\$ '
      eval "$(direnv hook bash)"
    '';
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
        pager = "less -FRX";
      };
      merge = { conflictstyle = "diff3"; tool = "nvim"; };
      diff = {
        colorMoved = "default";
        algorithm = "histogram";
        compactionHeuristic = true;
        mnemonicPrefix = true;
        wsErrorHighlight = "all";
      };
      alias = {
        a = "add";
        b = "branch -vva";
        c = "commit";
        d = "diff";
        D = "diff --cached";
        l = "log --oneline --graph --decorate --all";
        m = "merge";
        p = "pull";
        P = "push";
        s = "status --short";
        S = "status";
      };
      fetch = { prune = true; prunetags = true; };
      push = { default = "current"; followTags = true; };
      help = { autocorrect = -1; };
      pull = { ff = "only"; rebase = false; };
      url = { "ssh://git@github.com/".insteadOf = "https://github.com/"; };
      advice = {
        addIgnoredFile = false;
        forceDeleteBranch = false;
      };
    };
  };
}

