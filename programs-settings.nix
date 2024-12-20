{ ... }:
{
  programs.bash = {
    interactiveShellInit = '' PS1='[\D{%Y-%m-%d}] [\t]:\w\$ ' '';
    enableCompletion = true;
  };

  programs.chromium = {
    enable = true;
    extraOpts = { "crash_reporter.enabled" = false; "breakpad.reportURL" = ""; };
  };

  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
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
      # git config advice.addIgnoredFile
      # git config pull.rebase false
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

