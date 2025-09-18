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
    -- UI Settings
    vim.opt.updatetime = 1000
    vim.opt.list = true

    vim.opt.listchars = {
      space = "·", tab = "  ", eol = "↴", trail = "·", extends = "⟩", precedes = "⟨"
    }

    vim.opt.cursorline = true
    vim.opt.cursorcolumn = true
    vim.opt.guicursor = 
      "n-v-c:block-Cursor/lCursor-blinkon0,i-ci-ve:ver25-Cursor/lCursor,r-cr:hor20,o:hor50"

    -- Set up distinct colors for cursor, cursorline and matching brackets
    vim.api.nvim_create_autocmd({"ColorScheme", "VimEnter"}, {
      pattern = "*",
      callback = function()
        vim.api.nvim_set_hl(0, 'Cursor', { fg = '#000000', bg = '#ff0000', bold = true })
        vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#101010' })
        vim.api.nvim_set_hl(0, 'MatchParen', { fg = '#000000', bg = '#0000ff', bold = true })
      end
    })

    -- Create :W alias for :write
    vim.api.nvim_create_user_command('W', 'write', {})

    -- Telescope configuration and search functionality
    -- Store last search term and mode globally
    _G.last_telescope_search = ""
    _G.last_telescope_mode = "literal" -- "literal" or "regex"

    -- Custom live_grep functions with regex support
    local function live_grep_literal()
      _G.last_telescope_mode = "literal"
      require('telescope.builtin').live_grep({
        additional_args = function()
          return {"--fixed-strings"}
        end,
        prompt_title = "Live Grep (LITERAL)"
      })
    end

    local function live_grep_regex()
      _G.last_telescope_mode = "regex"
      require('telescope.builtin').live_grep({
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--pcre2"
        },
        prompt_title = "Live Grep (REGEX)"
      })
    end

    -- Set up telescope mappings for search save/restore using autocmds
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "TelescopePrompt",
      callback = function()
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')
        
        -- Set buffer-local keymaps for telescope prompt
        vim.keymap.set('i', '<C-s>', function()
          local prompt_bufnr = vim.api.nvim_get_current_buf()
          _G.last_telescope_search = action_state.get_current_line()
          vim.notify("Search saved: " .. _G.last_telescope_search)
        end, { buffer = true, silent = true })
        
        vim.keymap.set('i', '<C-x>', function()
          _G.last_telescope_search = ""
          vim.notify("Search history cleared")
        end, { buffer = true, silent = true })
        
        -- Navigation in insert mode
        vim.keymap.set('i', '<C-j>', function()
          actions.move_selection_next(vim.api.nvim_get_current_buf())
        end, { buffer = true, silent = true })
        
        vim.keymap.set('i', '<C-k>', function()
          actions.move_selection_previous(vim.api.nvim_get_current_buf())
        end, { buffer = true, silent = true })
      end,
    })

    -- Register global functions so you can call them from keymaps
    _G.live_grep_literal = live_grep_literal
    _G.live_grep_regex = live_grep_regex

    -- Custom function to start live_grep with last search term and mode
    local function live_grep_with_last_search()
      if _G.last_telescope_search ~= "" then
        if _G.last_telescope_mode == "regex" then
          require('telescope.builtin').live_grep({
            default_text = _G.last_telescope_search,
            vimgrep_arguments = {
              "rg", "--color=never", "--no-heading", "--with-filename",
              "--line-number", "--column", "--smart-case", "--pcre2"
            },
            prompt_title = "Live Grep (REGEX)"
          })
        else
          require('telescope.builtin').live_grep({
            default_text = _G.last_telescope_search,
            additional_args = function() return {"--fixed-strings"} end,
            prompt_title = "Live Grep (LITERAL)"
          })
        end
      else
        live_grep_literal()
      end
    end

    -- Custom function for resuming last picker
    local function resume_last_picker()
      require('telescope.builtin').resume()
    end

    -- Function to clear search history
    local function clear_search_history()
      _G.last_telescope_search = ""
      vim.notify("Search history cleared")
    end

    -- Register global functions
    _G.live_grep_with_last_search = live_grep_with_last_search
    _G.resume_last_telescope = resume_last_picker
    _G.clear_telescope_search = clear_search_history

    -- Git workflow functions
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
          
          -- Regular enter - opens current version
          map('i', '<CR>', function(prompt_bufnr)
            local selection = require('telescope.actions.state').get_selected_entry()
            actions.close(prompt_bufnr)
            if selection then
              vim.cmd('edit ' .. selection.value)
              vim.schedule(function()
                vim.cmd('normal! ]h')
              end)
            end
          end)

          -- Shift+enter - opens the previous version
          map('i', '<S-CR>', function(prompt_bufnr)
            local selection = require('telescope.actions.state').get_selected_entry()
            actions.close(prompt_bufnr)
            if selection then
              vim.cmd('enew')  -- Create new buffer
              vim.cmd('read !git show HEAD:' .. selection.value)
              vim.cmd('0delete')  -- Remove extra blank line
              vim.bo.modified = false
              vim.bo.readonly = true
              -- Set buffer name to indicate it's the old version
              vim.cmd('file OLD_' .. selection.value)
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
           _G.git_nav_state.current_index = 
              (_G.git_nav_state.current_index - 2 + #files) % #files + 1
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

    -- Git commit workflow functions
    local function smart_git_commit()
      -- Check if we have staged changes
      local staged_handle = io.popen("git diff --cached --quiet; echo $?")
      local staged_result = staged_handle:read("*a"):gsub("%s+", "")
      staged_handle:close()
      
      local has_staged = staged_result == "1"
      
      -- Check if we have unstaged changes
      local unstaged_handle = io.popen("git diff --quiet; echo $?")
      local unstaged_result = unstaged_handle:read("*a"):gsub("%s+", "")
      unstaged_handle:close()
      
      local has_unstaged = unstaged_result == "1"
      
      -- Determine which diff to show and which commit command to use
      local diff_cmd, commit_cmd
      
      if has_staged then
        -- Show staged changes
        diff_cmd = "git diff --cached"
        commit_cmd = "git commit"
      elseif has_unstaged then
        -- Show unstaged changes, will commit with -a
        diff_cmd = "git diff"
        commit_cmd = "git commit -a"
      else
        vim.notify("No changes to commit", vim.log.levels.WARN)
        return
      end
      
      -- Save current buffer if it exists and is modified
      if vim.bo.modified then
        vim.cmd('write')
      end
      
      -- Create horizontal split (diff on right, commit on left)
      vim.cmd('vsplit')
      
      -- Move to right split and open diff
      vim.cmd('wincmd l')
      vim.cmd('enew')
      vim.cmd('read !' .. diff_cmd)
      vim.cmd('0delete') -- Remove extra blank line
      vim.bo.readonly = true
      vim.bo.modified = false
      vim.bo.filetype = 'diff'
      vim.cmd('file COMMIT_DIFF')
      
      -- Move back to left split and start commit
      vim.cmd('wincmd h')
      vim.cmd('enew')
      
      -- Create the commit message file
      local commit_file = vim.fn.tempname() .. '_COMMIT_EDITMSG'
      vim.cmd('edit ' .. commit_file)
      vim.bo.filetype = 'gitcommit'
      
      -- Set up autocommand to actually commit when we save and quit
      vim.api.nvim_create_autocmd({"BufWritePost"}, {
        buffer = vim.api.nvim_get_current_buf(),
        once = true,
        callback = function()
          -- Read the commit message
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local commit_msg = table.concat(lines, "\n"):gsub("^%s*(.-)%s*$", "%1")
          
          if commit_msg == "" or commit_msg:match("^#") then
            vim.notify("Empty commit message, aborting", vim.log.levels.WARN)
            return
          end

          -- Write message to temp file
          local msg_file = vim.fn.tempname()
          local file = io.open(msg_file, "w")
          file:write(commit_msg)
          file:close()
          
          -- Execute commit
          local cmd = commit_cmd .. ' -F "' .. msg_file .. '"'
          local handle = io.popen(cmd .. ' 2>&1')
          local result = handle:read("*a")
          local success = handle:close()
          
          -- Clean up temp file
          os.remove(msg_file)
          
          if success then
            vim.notify("Commit successful!")
            -- Close both windows
            vim.schedule(function()
              vim.cmd('bd!')
              if vim.api.nvim_win_is_valid(vim.fn.win_getid(vim.fn.winnr('#'))) then
                vim.cmd('wincmd l')
                vim.cmd('bd!')
              end
            end)
          else
            vim.notify("Commit failed : '" .. result .. "'", vim.log.levels.ERROR)
          end
        end
      })
      
      -- Set up template commit message
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {
        "",
        "",
        "# Please enter the commit message for your changes.",
        "# Lines starting with '#' will be ignored.",
        "# An empty message aborts the commit.",
        "#",
        "# " .. (has_staged and "changes to commit :" or 
                "changes to commit (stage all):"),
      })
      
      -- Position cursor at the beginning
      vim.api.nvim_win_set_cursor(0, {1, 0})
      vim.cmd('startinsert')
    end

    -- Function to run git commands in terminal buffers with colors
    _G.run_git_command = function(command, split_type)
      split_type = split_type or "tab"  -- Default to tab
      
      -- Create the appropriate split/tab
      if split_type == "tab" then
        vim.cmd("tabnew")
      elseif split_type == "vsplit" then
        -- Open vsplit on the right side
        vim.cmd("rightbelow vnew")
      else
        vim.cmd("new")
      end
      
      -- Get the new buffer
      local buf = vim.api.nvim_get_current_buf()
      
      -- Set buffer options
      vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
      vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
      vim.api.nvim_buf_set_option(buf, "swapfile", false)
      
      -- Set buffer name
      local bufname = "Git_" .. string.gsub(command, "[^%w]", "_")
      vim.api.nvim_buf_set_name(buf, bufname)
      
      -- Start terminal with the git command
      vim.fn.termopen(command, {
        on_exit = function(_, _)
          vim.cmd("stopinsert")
          -- Set buffer local mappings for easy exit
          vim.api.nvim_buf_set_keymap(buf, "n", "q", ":bd<CR>",
            {noremap = true, silent = true})
          vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":bd<CR>",
            {noremap = true, silent = true})
        end
      })
    end

    -- Register global functions
    _G.smart_git_commit = smart_git_commit

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

