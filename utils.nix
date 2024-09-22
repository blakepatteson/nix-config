{ config, pkgs, ... }:

{
  environment.etc."xdg/kitty/kitty.conf".text = ''
    font_family Victor Mono
    font_size 11.0
    scrollback_pager ${pkgs.neovim}/bin/nvim -c "set nonumber nolist showtabline=0 foldcolumn=0" -c "autocmd TermOpen * normal G" -c "silent write! /tmp/kitty_scrollback_buffer | te cat /tmp/kitty_scrollback_buffer - " -c "set clipboard=unnamedplus" -c "vmap y ygv<Esc>" -c "nnoremap y yy" -c "nnoremap Y y$" -c "let @+=@\"" -c "set clipboard=unnamedplus"
    scrollback_lines 10000
    allow_remote_control yes
    map ctrl+shift+m show_scrollback
  '';

  programs.bash = {
    enableCompletion = true;
    interactiveShellInit = ''
      PS1='[\D{%Y-%m-%d}] [\t]:\w\$ '
    '';
  };
}