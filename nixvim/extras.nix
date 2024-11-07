{ pkgs, ... }:
{
  programs.nixvim.extraPlugins = with pkgs.vimPlugins; [
    vim-visual-multi
  ];

  programs.nixvim.extraConfigVim = ''
    set list
    set listchars=space:·,eol:↴,tab:»\ ,trail:·,extends:⟩,precedes:⟨

    highlight ColorColumn ctermbg=236 guibg=#2d2d2d

    function! LspStatus() abort
      if luaeval('#vim.lsp.get_active_clients() > 0')
        return luaeval("require('lsp-status').status()")
      endif
      return
    endfunction
  '';
}
