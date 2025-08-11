{ pkgs, ... }:
{
  programs.nixvim.extraPlugins = with pkgs.vimPlugins; [ vim-visual-multi ];

  # have to do this for treesitter TODO: open issue with treesitter nixvim?
  programs.nixvim.extraConfigLuaPre = ''
    vim.fs = vim.fs or {}
    vim.fs.joinpath = vim.fs.joinpath or function(...)
      return table.concat({...}, '/')
    end
  '';

  programs.nixvim.extraConfigLua = ''
    -- Load modular configuration files
    dofile("${./ui-settings.lua}")
    dofile("${./telescope-config.lua}")
    dofile("${./git-workflow.lua}")

    -- TypeScript LSP setup (keeping this here since it's nix-specific)
    local lspconfig = require('lspconfig')
    lspconfig.ts_ls.setup({
      cmd = { 
        "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server", 
        "--stdio" 
      },
      filetypes = { "typescript", "javascript" },
      root_dir = lspconfig.util.root_pattern(
        "package.json", "tsconfig.json", "jsconfig.json", ".git"),
      single_file_support = true,
      init_options = {
        hostInfo = "neovim",
        preferences = {
          includeInlayParameterNameHints = "all",
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          noUnusedLocals = true,
          noUnusedParameters = true,
        },
        capabilities = { renameProvider = true }
      }
    });
  '';

  programs.nixvim.extraConfigVim = /* lua */ ''
    highlight ColorColumn ctermbg = 236 guibg=#2d2d2d
    function! LspStatus() abort
      if luaeval('#vim.lsp.get_active_clients() > 0')
          return luaeval("require('lsp-status').status()")
      endif
    return
    endfunction

    set cedit=\<C-o>
  '';
}

