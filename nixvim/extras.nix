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
    lua << EOF
      local lspconfig = require('lspconfig')
      
      -- Configure tsserver directly
      lspconfig.tsserver.setup({
        cmd = { "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server", "--stdio" },
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "typescript.tsx" },
        root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
        single_file_support = true,
        init_options = {
          preferences = {
            includeInlayParameterNameHints = "all",
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
          }
        }
      })
    EOF
  '';
}
