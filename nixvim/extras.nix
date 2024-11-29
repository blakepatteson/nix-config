{ pkgs, ... }:
{
  programs.nixvim.extraPlugins = with pkgs.vimPlugins; [ vim-visual-multi ];
  # have to do this for treesitter
  programs.nixvim.extraConfigLuaPre = ''
    vim.fs = vim.fs or {}
    vim.fs.joinpath = vim.fs.joinpath or function(...)
      return table.concat({...}, '/')
    end
  '';
  programs.nixvim.extraConfigLua = ''
    vim.opt.updatetime = 300
    
      -- Workspace-wide git hunks function
      local function workspace_git_hunks()
        require('telescope.builtin').git_status({
          git_command = { "git", "diff", "--unified=1" },
          attach_mappings = function(_, map)
            local actions = require('telescope.actions')
            map('i', '<CR>', function(prompt_bufnr)
              local selection = require('telescope.actions.state').get_selected_entry()
              actions.close(prompt_bufnr)
              if selection then
                vim.cmd('edit ' .. selection.value)
                -- Jump to the first change in the file
                vim.schedule(function()
                  vim.cmd('normal! ]h')
                end)
              end
            end)
            return true
          end
        })
      end
    
      -- Register the command
      vim.api.nvim_create_user_command('WorkspaceGitHunks', workspace_git_hunks, {})
  '';
  programs.nixvim.extraConfigVim = /* lua */ ''
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
