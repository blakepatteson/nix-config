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
  '';
}
