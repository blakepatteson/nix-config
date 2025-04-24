{ pkgs, ... }:
{
  environment.etc."xdg/kitty/kitty.conf".text = ''
    font_family Victor Mono
    font_size 20.0
    scrollback_pager bash -c 'TMPFILE="/tmp/kitty_scrollback_$(date +%s%N)"; ${pkgs.neovim}/bin/nvim -c "set nonumber nolist showtabline=0 foldcolumn=0" -c "autocmd TermOpen * normal G" -c "silent write! $TMPFILE | te cat $TMPFILE - " -c "autocmd VimLeave * !rm -f $TMPFILE" -c "set clipboard=unnamedplus" -c "vmap y ygv<Esc>" -c "nnoremap y yy" -c "nnoremap Y y$" -c "let @+=@\"" -c "set clipboard=unnamedplus"'
    scrollback_lines 10000
    allow_remote_control yes
    map ctrl+shift+m show_scrollback
    map ctrl+v paste_from_clipboard
    map ctrl+q close_tab
    
    map ctrl+l clear_terminal scroll active
    map ctrl+equal change_font_size all +2.0
    map ctrl+minus change_font_size all -2.0
    map ctrl+backspace change_font_size all 0

    # New scrolling mappings
    map ctrl+u scroll_page_up
    map ctrl+d scroll_page_down

    # Vi mode specific mappings
    map ctrl+shift+j scroll_line_down
    map ctrl+shift+k scroll_line_up
    map ctrl+shift+h scroll_to_prompt -1
    map ctrl+shift+l scroll_to_prompt 1
    map ctrl+shift+g scroll_to_prompt 0
    map ctrl+shift+G scroll_to_prompt -1

    # unmappings
    map ctrl+shift+r no_op
  '';

  environment.etc.bashrc = {
    text = ''
      # ~/.bashrc: executed by bash(1) for non-login shells.

      # If not running interactively, don't do anything
      [ -z "$PS1" ] && return

      # don't put duplicate lines in the history.
      HISTCONTROL=ignoredups:ignorespace

      # append to the history file, don't overwrite it
      shopt -s histappend

      # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
      HISTSIZE=1000
      HISTFILESIZE=2000

      # check the window size after each command and, if necessary,
      # update the values of LINES and COLUMNS.
      shopt -s checkwinsize

      # make less more friendly for non-text input files, see lesspipe(1)
      # [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

      # set a fancy prompt with date and time
      PS1='\[\033[01;31m\][\D{%Y-%m-%d}]\[\033[00m\] \[\033[01;32m\][\t]\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

      # enable color support of ls and also add handy aliases
      if [ -x /usr/bin/dircolors ]; then
          test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
          alias ls='ls --color=auto'
          alias grep='grep --color=auto'
          alias fgrep='fgrep --color=auto'
          alias egrep='egrep --color=auto'
      fi

      # some more ls aliases
      alias l='ls -al'
      alias la='ls -A'
      alias list-issues='gh issue list --limit 1000'
      alias n='nvim'

      alias dkill='sudo docker kill $(sudo docker ps -q)'
      alias dkillrm='sudo docker rm -f $(sudo docker ps -aq)'

      alias cls='clear && printf "\033[3J"'

      alias battery='acpi'
    '';
    mode = "0644";
  };

  # This ensures that the /etc/bashrc file is sourced for interactive non-login shells
  environment.interactiveShellInit = ''
    if [ -f /etc/bashrc ]; then
      . /etc/bashrc
    fi
  '';
}
