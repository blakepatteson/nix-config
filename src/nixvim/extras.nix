{ pkgs, ... }:
{
  programs.nixvim.extraPlugins = with pkgs.vimPlugins; [ vim-visual-multi ];

  programs.nixvim.extraConfigLuaPre = ''
    vim.g.VM_maps = {
      ["Add Cursor Down"]    = '<M-Down>',
      ["Add Cursor Up"]      = '<M-Up>',
      ["Find Under"]         = '<M-d>',
      ["Find Subword Under"] = '<M-d>',
    }

    vim.fs = vim.fs or {}
    vim.fs.joinpath = vim.fs.joinpath or function(...)
      return table.concat({...}, '/')
    end
  '';

  programs.nixvim.extraConfigLua = ''
    local null_ls = require("null-ls")
    null_ls.register(null_ls.builtins.formatting.prettier.with({
      prefer_local = false,
    }))

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
        vim.api.nvim_set_hl(0, 'MatchParen',
            { fg = '#000000', bg = '#0000ff', bold = true })
      end
    })

    -- Create :W alias for :write
    vim.api.nvim_create_user_command('W', 'write', {})

    -- Insert a sequence of numbers below cursor (<leader>in)
    vim.api.nvim_create_user_command("InsertNumbers", function(opts)
      local args = vim.split(opts.args, " ")
      local start = tonumber(args[1]) or 1
      local finish = tonumber(args[2]) or 10
      local row = vim.api.nvim_win_get_cursor(0)[1]
      local lines = {}
      for i = start, finish do table.insert(lines, tostring(i)) end
      vim.api.nvim_buf_set_lines(0, row, row, false, lines)
    end, { nargs = "*" })

    vim.api.nvim_create_user_command("AddLineNumbers", function()
      vim.cmd([[%s/^/\=line('.'). ' '/]])
      vim.cmd("nohlsearch")
    end, {})

    _G.prompt_insert_numbers = function()
      vim.ui.input({ prompt = "Start End: " }, function(s)
        if s then vim.cmd("InsertNumbers " .. s) end
      end)
    end

    _G.prompt_qa = function()
      vim.ui.input({ prompt = "Number of Q&A pairs: " }, function(n)
        vim.cmd("QA " .. (n or "3"))
      end)
    end

    vim.api.nvim_create_user_command("QA", function(opts)
      local n = tonumber(opts.args) or 3
      local lines = {}
      for i = 1, n do
        table.insert(lines, string.format("Q%d)", i))
        table.insert(lines, string.format("A%d)", i))
        if i < n then table.insert(lines, "") end
      end
      local row = vim.api.nvim_win_get_cursor(0)[1]
      vim.api.nvim_buf_set_lines(0, row, row, false, lines)
    end, { nargs = "?" })


    -- Telescope configuration and search functionality
    -- Store last search term and mode globally
    _G.last_telescope_search = ""
    _G.last_telescope_mode = "literal" -- "literal" or "regex"
    _G.telescope_file_filter = "" -- persistent file filter (e.g., "*.go", "*.ts")

    -- Custom live_grep functions with regex support
    local function live_grep_literal()
      _G.last_telescope_mode = "literal"
      local opts = {
        additional_args = function()
          local args = {"--fixed-strings"}
          if _G.telescope_file_filter ~= "" then
            table.insert(args, "--glob")
            table.insert(args, _G.telescope_file_filter)
          end
          return args
        end,
        prompt_title = "Live Grep (LITERAL)" .. (_G.telescope_file_filter ~= "" and
            " [" .. _G.telescope_file_filter .. "]" or "")
      }
      require('telescope.builtin').live_grep(opts)
    end

    local function live_grep_regex()
      _G.last_telescope_mode = "regex"
      local opts = {
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
        additional_args = function()
          if _G.telescope_file_filter ~= "" then
            local args = {}
            for pattern in string.gmatch(_G.telescope_file_filter, "[^,]+") do
              table.insert(args, "--glob")
              table.insert(args, pattern)
            end
            return args
          end
          return {}
        end,
        prompt_title = "Live Grep (REGEX)" .. (_G.telescope_file_filter ~= "" and
            " [" .. _G.telescope_file_filter .. "]" or "")
      }
      require('telescope.builtin').live_grep(opts)
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
          vim.notify("Search saved: " .. "<" .. _G.last_telescope_search .. ">")
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
          local opts = {
            default_text = _G.last_telescope_search,
            vimgrep_arguments = {
              "rg", "--color=never", "--no-heading", "--with-filename",
              "--line-number", "--column", "--smart-case", "--pcre2"
            },
            additional_args = function()
              if _G.telescope_file_filter ~= "" then
                local args = {}
                for pattern in string.gmatch(_G.telescope_file_filter, "[^,]+") do
                  table.insert(args, "--glob")
                  table.insert(args, pattern)
                end
                return args
              end
              return {}
            end,
            prompt_title = "Live Grep (REGEX)" .. (_G.telescope_file_filter ~= "" and
                " [" .. _G.telescope_file_filter .. "]" or "")
          }
          require('telescope.builtin').live_grep(opts)
        else
          local opts = {
            default_text = _G.last_telescope_search,
            additional_args = function()
              local args = {"--fixed-strings"}
              if _G.telescope_file_filter ~= "" then
                table.insert(args, "--glob")
                table.insert(args, _G.telescope_file_filter)
              end
              return args
            end,
            prompt_title = "Live Grep (LITERAL)" .. (_G.telescope_file_filter ~= "" and
                " [" .. _G.telescope_file_filter .. "]" or "")
          }
          require('telescope.builtin').live_grep(opts)
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

    -- Function to set file filter
    local function set_telescope_filter()
      local input = vim.fn.input({
        prompt = "File filter : ", default = _G.telescope_file_filter
      })

      _G.telescope_file_filter = input
      if input == "" then vim.notify("File filter cleared")
      else                vim.notify("File filter set: " .. input)
      end
    end

    -- Register global functions
    _G.live_grep_with_last_search = live_grep_with_last_search
    _G.resume_last_telescope      = resume_last_picker
    _G.clear_telescope_search     = clear_search_history
    _G.set_telescope_filter       = set_telescope_filter

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
              vim.schedule(function() vim.cmd('normal! ]h') end)
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

    -- Workspace-wide git staged changes function
    local function workspace_git_staged()
      require('telescope.builtin').git_status({
        git_command = { "git", "diff", "--cached", "--unified=1" },
        attach_mappings = function(_, map)
          local actions = require('telescope.actions')

          -- Regular enter - opens current version
          map('i', '<CR>', function(prompt_bufnr)
            local selection = require('telescope.actions.state').get_selected_entry()
            actions.close(prompt_bufnr)
            if selection then
              vim.cmd('edit ' .. selection.value)
              vim.schedule(function() vim.cmd('normal! ]h') end)
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
    vim.api.nvim_create_user_command('WorkspaceGitStaged', workspace_git_staged, {})

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

    -- Hook VM start/exit to swap p/P for distributed paste while VM is active
    vim.api.nvim_create_autocmd("User", {
      pattern = "visual_multi_start",
      callback = function()
        vim.keymap.set("n", "p", function() _G.vm_distributed_paste(true) end,
          { buffer = true, desc = "VM distributed paste (after)" })
        vim.keymap.set("n", "P", function() _G.vm_distributed_paste(false) end,
          { buffer = true, desc = "VM distributed paste (before)" })
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "visual_multi_exit",
      callback = function()
        pcall(vim.keymap.del, "n", "p", { buffer = true })
        pcall(vim.keymap.del, "n", "P", { buffer = true })
      end,
    })

    -- Distributed paste: when VM is active and clipboard has N lines matching N
    -- cursors, paste line[i] at cursor[i]. Otherwise fall back to standard paste.
    -- Mimics VS Code's multi-cursor copy/paste behavior.
    _G.vm_distributed_paste = function(after)
      local reg = vim.fn.getreg('"')
      local regtype = vim.fn.getregtype('"')

      local lines
      if regtype == "V" or regtype:sub(1, 1) == "\22" then
        lines = vim.split(reg:gsub("\n$", ""), "\n", { plain = true })
      else
        lines = vim.split(reg, "\n", { plain = true })
      end

      local vm = vim.b.VM_Selection
      local regions = vm and vm.Regions or nil

      if not regions or #regions == 0 or #regions ~= #lines then
        local key = after and "p" or "P"
        vim.cmd("normal! " .. key)
        return
      end

      local sorted = {}
      for i, r in ipairs(regions) do sorted[i] = { idx = i, l = r.l, a = r.a, region = r } end
      table.sort(sorted, function(x, y)
        if x.l ~= y.l then return x.l < y.l end
        return x.a < y.a
      end)

      for i = #sorted, 1, -1 do
        local r = sorted[i].region
        local line_idx = r.l - 1
        local buf_line = vim.api.nvim_buf_get_lines(
          0, line_idx, line_idx + 1, false)[1] or ""
        local is_point = (r.a == r.b)
        local col
        if is_point then
          col = r.a - 1
          if after then col = math.min(col + 1, #buf_line) end
        else
          col = after and math.min(r.b, #buf_line) or (r.a - 1)
        end
        if col < 0 then col = 0 end
        local before_txt = buf_line:sub(1, col)
        local after_txt = buf_line:sub(col + 1)
        vim.api.nvim_buf_set_lines(0, line_idx, line_idx + 1,
          false, { before_txt .. lines[i] .. after_txt })
      end

      vim.fn.feedkeys(vim.api.nvim_replace_termcodes(
        "<Esc><Esc>", true, false, true), "n")
    end

    -- VLINE -> VM cursors at first non-blank of each selected line
    _G.vm_cursors_at_line_starts = function()
      local s = vim.fn.getpos("v")[2]
      local e = vim.fn.getpos(".")[2]
      if s == 0 or e == 0 then
        s = vim.fn.getpos("'<")[2]
        e = vim.fn.getpos("'>")[2]
      end
      if s == 0 or e == 0 then
        vim.notify("vm_cursors: no selection found", vim.log.levels.WARN)
        return
      end
      if s > e then s, e = e, s end

      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
      vim.api.nvim_win_set_cursor(0, { s, 0 })
      vim.cmd("normal! ^")
      local add_down = vim.api.nvim_replace_termcodes(
        "<Plug>(VM-Add-Cursor-Down)", true, false, true)
      for _ = s + 1, e do
        vim.api.nvim_feedkeys(add_down, "x", false)
      end
    end

    -- Oil column detail toggle
    _G.oil_detail_on = false
    _G.toggle_oil_detail = function()
      if _G.oil_detail_on then
        require("oil").set_columns({ "icon" })
        _G.oil_detail_on = false
      else
        require("oil").set_columns({ "icon", "size", "mtime" })
        _G.oil_detail_on = true
      end
    end

    -- Oil file manager function for copying file paths
    local function copy_oil_file_path()
      local oil = require('oil')
      local entry = oil.get_cursor_entry()
      if entry and entry.name then
        local dir = oil.get_current_dir()
        local path = (dir:sub(-1) == '/' and dir:sub(1, -2) or dir) .. '/' .. entry.name
        vim.fn.setreg('+', path)
        vim.notify('Copied: ' .. path)
      else
        vim.notify('No file under cursor', vim.log.levels.WARN)
      end
    end

    -- Register global functions
    _G.copy_oil_file_path = copy_oil_file_path

    -- TypeScript LSP setup (keeping this here since it's nix-specific)
    vim.lsp.config.ts_ls = {
      cmd = {
        "${pkgs.typescript-language-server}/bin/typescript-language-server",
        "--stdio"
      },
      filetypes = { "typescript", "javascript" },
      root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
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
    }
    vim.lsp.enable('ts_ls')

    -- Odinfmt custom formatter setup
    local null_ls = require("null-ls")
    local helpers = require("null-ls.helpers")

    local odinfmt = {
      method    = null_ls.methods.FORMATTING,
      filetypes = { "odin" },
      generator = helpers.formatter_factory({
        command  = "odinfmt", args = { "-stdin", "$FILENAME" }, to_stdin = true,
      }),
    }

    null_ls.register(odinfmt);
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

