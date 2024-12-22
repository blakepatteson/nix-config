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
    vim.opt.updatetime = 300
    vim.opt.list = true

    vim.opt.listchars = {
      space = "·",
      tab = "  ",
      eol = "↴",
      trail = "·",
      extends = "⟩",
      precedes = "⟨"
    }
  
    -- Workspace-wide git navigation functions
    local function get_git_files_with_changes()
      local handle = io.popen("git diff --name-only")
      if not handle then return {} end
   
      local result = handle:read("*a")
      handle:close()
   
      local files = {}
      for file in result:gmatch("[^\n]+") do
        table.insert(files, file)
      end
      return files
    end

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

    -- Global state for tracking current position
    _G.git_nav_state = { files = {}, current_index = 0 }

    local function navigate_git_changes(direction)
       local files = get_git_files_with_changes()
       if #files == 0 then
         vim.notify("No files with git changes found")
         return
       end

       -- Update state
       if vim.deep_equal(_G.git_nav_state.files, files) then
         -- Same files, update index
         if direction == "next" then
           _G.git_nav_state.current_index = (_G.git_nav_state.current_index % #files) + 1
         else
           _G.git_nav_state.current_index = (_G.git_nav_state.current_index - 2 + #files) % #files + 1
         end
       else
         -- New set of files
         _G.git_nav_state.files = files
         _G.git_nav_state.current_index = direction == "next" and 1 or #files
       end

       -- Navigate to file
       local target_file = files[_G.git_nav_state.current_index]
       vim.cmd('edit ' .. target_file)
    
       -- Jump to first hunk in file
       vim.schedule(function()
         require('gitsigns').next_hunk()
       end)
     end

     -- Register commands for navigation
     vim.api.nvim_create_user_command('NextGitFile', function()
       navigate_git_changes("next")
     end, {})
  
     vim.api.nvim_create_user_command('PrevGitFile', function()
       navigate_git_changes("prev")
     end, {})

      -- Floating Terminal Configuration
      local float_term = nil
      local float_term_win = nil
      local float_term_buf = nil

      local function create_float_term()
        -- Get dimensions
        local width = vim.api.nvim_get_option("columns")
        local height = vim.api.nvim_get_option("lines")
        
        -- Calculate floating window size
        local win_height = math.ceil(height * 0.8)
        local win_width = math.ceil(width * 0.8)
        
        -- Calculate starting position
        local row = math.ceil((height - win_height) / 2)
        local col = math.ceil((width - win_width) / 2)
        
        -- Create buffer
        float_term_buf = vim.api.nvim_create_buf(false, true)
        
        -- Set window options
        local win_opts = {
          relative = "editor",
          width = win_width,
          height = win_height,
          row = row,
          col = col,
          style = "minimal",
          border = "rounded"
        }
        
        -- Create window
        float_term_win = vim.api.nvim_open_win(float_term_buf, true, win_opts)
        
        -- Set terminal buffer options
        vim.wo[float_term_win].winblend = 0
        vim.wo[float_term_win].winhl = 'Normal:Normal'
        
        -- Create terminal
        float_term = vim.fn.termopen(vim.o.shell, {
          on_exit = function()
            float_term = nil
            if float_term_win and vim.api.nvim_win_is_valid(float_term_win) then
              vim.api.nvim_win_close(float_term_win, true)
              float_term_win = nil
            end
            if float_term_buf and vim.api.nvim_buf_is_valid(float_term_buf) then
              vim.api.nvim_buf_delete(float_term_buf, { force = true })
              float_term_buf = nil
            end
          end
        })
        
        -- Set buffer options
        vim.bo[float_term_buf].filetype = "terminal"
        vim.bo[float_term_buf].buflisted = false
        
        -- Enter terminal mode automatically
        vim.cmd('startinsert')
      end

      local function toggle_float_term()
        if float_term == nil then
          create_float_term()
        else
          if vim.api.nvim_win_is_valid(float_term_win) then
            vim.api.nvim_win_close(float_term_win, true)
            float_term_win = nil
          end
          float_term = nil
        end
      end

      -- Create command for the floating terminal
      vim.api.nvim_create_user_command('ToggleTerminal', toggle_float_term, {})

      local lspconfig = require('lspconfig')
            
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
  '';
  programs.nixvim.extraConfigVim = /* lua */ ''
    highlight ColorColumn ctermbg=236 guibg=#2d2d2d
    function! LspStatus() abort
    if luaeval('#vim.lsp.get_active_clients() > 0')
    return luaeval("require('lsp-status').status()")
    endif
    return
    endfunction
  '';
}

