{ config, pkgs, ... }:
{
  environment.etc."xdg/kitty/kitty.conf".text = ''
    font_family Victor Mono
    font_size 20.0
    scrollback_pager ${pkgs.neovim}/bin/nvim -c "set nonumber nolist showtabline=0 foldcolumn=0" -c "autocmd TermOpen * normal G" -c "silent write! /tmp/kitty_scrollback_buffer | te cat /tmp/kitty_scrollback_buffer - " -c "set clipboard=unnamedplus" -c "vmap y ygv<Esc>" -c "nnoremap y yy" -c "nnoremap Y y$" -c "let @+=@\"" -c "set clipboard=unnamedplus"
    scrollback_lines 10000
    allow_remote_control yes
    map ctrl+shift+m show_scrollback
    map ctrl+v paste_from_clipboard
    map ctrl+c copy_to_clipboard
    map ctrl+n new_os_window
    map ctrl+w close_window
    map ctrl+t new_tab
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
  '';
}