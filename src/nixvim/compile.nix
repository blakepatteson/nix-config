{ ... }:
{
  programs.nixvim = {
    extraConfigLua = ''
      _G.compile_job_id = nil

      -- Compile Command Functionality
      _G.compile_command = {
        command = "",
        history = {},
        history_set = {},   -- Set-like table for fast dedupe
        history_index = 0,
        buffer_counter = 0, -- Counter to ensure unique buffer names
        current_command = nil,
      }

      -- Store command history in Neovim's data dir, e.g. ~/.local/share/nvim
      local compile_history_dir = vim.fn.stdpath("data") .. "/compile"
      vim.fn.mkdir(compile_history_dir, "p")
      local compile_history_file = compile_history_dir .. "/commands.json"

      -- Save history (list) to disk; the set is rebuilt on load
      local function save_history()
        local ok, encoded = pcall(vim.json.encode, _G.compile_command.history)
        if not ok then return end
        local f = io.open(compile_history_file, "w")
        if not f then return end
        f:write(encoded)
        f:close()
      end

      -- Load history from disk; rebuild set and keep insertion order
      local function load_history()
        local f = io.open(compile_history_file, "r")
        if not f then return end
        local content = f:read("*a")
        f:close()
        local ok, data = pcall(vim.json.decode, content)
        if not ok or type(data) ~= "table" then return end

        _G.compile_command.history = {}
        _G.compile_command.history_set = {}
        for _, cmd in ipairs(data) do
          if type(cmd) == "string" and
            cmd ~= "" and
            not _G.compile_command.history_set[cmd] then
              table.insert(_G.compile_command.history, cmd)
              _G.compile_command.history_set[cmd] = true
          end
        end
      end

      -- Insert with dedupe (move-to-front) + cap + persist
      local function add_to_history(cmd)
        if not cmd or cmd == "" then return end

        if _G.compile_command.history_set[cmd] then
          -- Remove previous occurrence
          for i, v in ipairs(_G.compile_command.history) do
            if v == cmd then
              table.remove(_G.compile_command.history, i)
              break
            end
          end
        else
          _G.compile_command.history_set[cmd] = true
        end

        table.insert(_G.compile_command.history, 1, cmd)

        -- cap to avoid unbounded growth
        local cap = 200
        while #_G.compile_command.history > cap do
          local removed = table.remove(_G.compile_command.history)
          _G.compile_command.history_set[removed] = nil
        end

        save_history()
      end

      -- Load once on startup
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true, callback = function() load_history() end,
      })

      -- Save on exit just in case
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function() save_history() end,
      })

      -- Function to jump to error location from compile output
      _G.jump_to_error = function()
        local line = vim.api.nvim_get_current_line()

        local patterns = {
          go = "([^:]+%.go):(%d+):(%d+):",
          generic = "([^:%s]+):(%d+):(%d+):",
          simple = "([^:%s]+):(%d+):",
          rust = "([^:]+%.rs):(%d+):(%d+):",
          c = "([^:]+%.[ch]p?p?):(%d+):(%d+):",
          python = 'File "([^"]+)", line (%d+)',
          nix = "([^:]+%.nix):(%d+):(%d+):",
        }

        local file, line_num, col_num

        for _, pattern in pairs(patterns) do
          file, line_num, col_num = line:match(pattern)
          if file then
            break
          end
        end

        if not file then
          file, line_num = line:match("([^:%s]+):(%d+)")
        end

        if not file or not line_num then
          vim.notify("No file location found on current line", vim.log.levels.WARN)
          return
        end

        line_num = tonumber(line_num)
        col_num = tonumber(col_num) or 1

        local file_path = file
        if vim.fn.filereadable(file_path) == 0 then
          if not file:match("^/") then
            local cwd = vim.fn.getcwd()
            local potential_paths = {
              cwd .. "/" .. file,
              cwd .. "/src/" .. file,
              cwd .. "/../" .. file,
            }

            for _, path in ipairs(potential_paths) do
              if vim.fn.filereadable(path) == 1 then
                file_path = path
                break
              end
            end
          end
        end

        if vim.fn.filereadable(file_path) == 0 then
          vim.notify("File not found: " .. file_path, vim.log.levels.ERROR)
          return
        end

        -- Open the file in a new window/buffer
        vim.cmd("wincmd p")  -- Go to previous window
        if vim.fn.bufexists(file_path) == 1 then
          vim.cmd("buffer " .. vim.fn.bufnr(file_path))
        else
          vim.cmd("edit " .. file_path)
        end

        -- Jump to the line and column
        vim.api.nvim_win_set_cursor(0, {line_num, col_num - 1})

        -- Center the line on screen
        vim.cmd("normal! zz")
      end

      _G.prompt_compile_command = function()
        -- Save the current command if history index is at current command
        if _G.compile_command.history_index == 0 and _G.compile_command.command ~= "" then
          add_to_history(_G.compile_command.command)
        end

        -- Prompt for command with existing as default
        local input_command = vim.fn.input({
          prompt = "Compile > ",
          default = _G.compile_command.command,
          completion = "shellcmd"
        })

        -- Update command and persist
        if input_command ~= "" then
          _G.compile_command.command = input_command
          _G.compile_command.history_index = 0
          add_to_history(input_command)
        end

        return input_command ~= ""
      end

      _G.telescope_compile_history = function()
        if #_G.compile_command.history == 0 then
          vim.notify("No command history available", vim.log.levels.INFO)
          return
        end

        local pickers = require('telescope.pickers')
        local finders = require('telescope.finders')
        local conf = require('telescope.config').values
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')

        pickers.new({}, {
          prompt_title = "Compile Command History",
          finder = finders.new_table {
            results = _G.compile_command.history,
            entry_maker = function(entry)
              return { value = entry, display = entry, ordinal = entry }
            end,
          },
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                _G.compile_command.command = selection.value
                _G.run_compile_command()
              end
            end)
            return true
          end,
        }):find()
      end

      _G.browse_compile_history = function(direction)
        if #_G.compile_command.history == 0 then
          vim.notify("No command history available", vim.log.levels.INFO)
          return
        end

        -- Save current command if at index 0
        if _G.compile_command.history_index == 0 then
          _G.compile_command.current_command = _G.compile_command.command
        end

        -- Update index
        if direction == "prev" then
          _G.compile_command.history_index = math.min(
            _G.compile_command.history_index + 1, #_G.compile_command.history)
        else
          _G.compile_command.history_index = math.max(
            _G.compile_command.history_index - 1, 0)
        end

        -- Update command
        if _G.compile_command.history_index == 0 then
          _G.compile_command.command = _G.compile_command.current_command or ""
        else
          _G.compile_command.command =
            _G.compile_command.history[_G.compile_command.history_index]
        end
      end

      _G.clear_compile_command = function()
        _G.compile_command.command = ""
        _G.compile_command.history_index = 0
        _G.compile_command.history = {}
        _G.compile_command.history_set = {}
        _G.compile_command.current_command = nil
        pcall(vim.fn.delete, compile_history_file)
        vim.notify("Compile command cleared", vim.log.levels.INFO)
      end

      _G.run_compile_command = function()
        -- If no command set, prompt for one
        if _G.compile_command.command == "" then
          if not _G.prompt_compile_command() then
            return
          end
        end

        add_to_history(_G.compile_command.command)
        _G.compile_command.buffer_counter = _G.compile_command.buffer_counter + 1
        local output_dir = vim.fn.expand("~/.local/share/nvim/compile_outputs")
        vim.fn.mkdir(output_dir, "p")
        local timestamp = os.date("%Y%m%d_%H%M%S")
        local sanitized_cmd = string.gsub(_G.compile_command.command, "[^%w%-%.]", "_")
        local filename = timestamp .. "_" .. sanitized_cmd .. ".txt"
        local filepath = output_dir .. "/" .. filename

        vim.cmd("edit " .. vim.fn.fnameescape(filepath))
        local buf = vim.api.nvim_get_current_buf()

        vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
        vim.api.nvim_buf_set_option(buf, "swapfile", true)

        local header_lines = {
          "Running: " .. _G.compile_command.command,
          "Started at: " .. os.date("%Y-%m-%d %H:%M:%S"),
          "Working directory: " .. vim.fn.getcwd(),
          "Output saved to: " .. filepath,
          "------------------------------------------------------------",
          ""
        }

        vim.api.nvim_buf_set_lines(buf, 0, 0, false, header_lines)

        local line_count = 6
        local start_time = vim.loop.hrtime()
        local cmd = vim.fn.jobstart(_G.compile_command.command, {
          on_stdout = function(_, data)
            if data then
              if #data > 1 and data[#data] == "" then
                table.remove(data)
              end

              if #data > 0 then
                vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, data)
                line_count = line_count + #data
              end
            end
          end,
          on_stderr = function(_, data)
            if data then
              if #data > 1 and data[#data] == "" then
                table.remove(data)
              end

              if #data > 0 then
                vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, data)
                for i, line in ipairs(data) do
                  if line ~= "" then
                    local line_num = line_count - #data + i - 1
                    if line_num >= 0 and line_num < vim.api.nvim_buf_line_count(buf) then
                      vim.api.nvim_buf_add_highlight(buf, -1, "Error", line_num, 0, -1)
                    end
                  end
                end

                line_count = line_count + #data
              end
            end
          end,
          on_exit = function(_, exit_code)
            local end_time = vim.loop.hrtime()
            local duration_ns = end_time - start_time
            local duration_seconds = duration_ns / 1e9

            local duration_text
            if duration_seconds >= 60 then
              local minutes = math.floor(duration_seconds / 60)
              local seconds = duration_seconds % 60
              duration_text = string.format("%dm %.2fs", minutes, seconds)
            else
              duration_text = string.format("%.2fs", duration_seconds)
            end

            local footer_lines = {
              "",
              "------------------------------------------------------------",
              "Command completed with exit code: " .. exit_code,
              "Duration: " .. duration_text,
              "Finished at: " .. os.date("%Y-%m-%d %H:%M:%S")
            }

            vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, footer_lines)
            vim.cmd("silent write!")
            vim.api.nvim_buf_set_keymap(buf, "n", "q", ":bd<CR>",
              {noremap = true, silent = true})
            vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":bd<CR>",
              {noremap = true, silent = true})
            vim.api.nvim_buf_set_keymap(buf,
              "n", "r", ":lua _G.run_compile_command()<CR>",
              {noremap = true, silent = true, desc = "Run command again"})
            vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", ":lua _G.jump_to_error()<CR>",
              {noremap = true, silent = true, desc = "Jump to error location"})
            vim.api.nvim_buf_set_keymap(buf, "n", "gf", ":lua _G.jump_to_error()<CR>",
              {noremap = true, silent = true, desc = "Jump to error location"})

            vim.api.nvim_buf_set_option(buf, "filetype", "output")
          end,
          stdout_buffered = false,
          stderr_buffered = false,
        })

        if cmd <= 0 then
          vim.api.nvim_buf_set_lines(buf, line_count, line_count, false,
            {"Error: Failed to start command"})
          return
        end
        _G.compile_job_id = cmd
      end

      vim.api.nvim_create_user_command('CompileCommand', function()
        _G.prompt_compile_command()
      end, {})

      vim.api.nvim_create_user_command('CompileRun', function()
        _G.run_compile_command()
      end, {})

      vim.api.nvim_create_user_command('CompileClear', function()
        _G.clear_compile_command()
      end, {})

      vim.api.nvim_create_user_command('CompileKill', function()
        if _G.compile_job_id then
          vim.fn.jobstop(_G.compile_job_id)
          vim.notify("Compile job killed")
          _G.compile_job_id = nil
        else
          vim.notify("No active compile job to kill", vim.log.levels.WARN)
        end
      end, {})

      vim.api.nvim_create_autocmd({"BufEnter", "BufNew"}, {
        pattern = {"Output_*", "*.txt"},
        callback = function()
          local bufname = vim.api.nvim_buf_get_name(0)
          if not bufname:match("compile_outputs") then return end
          if vim.b.current_syntax then return end
          vim.cmd[[
            syntax match outputHeader /^Running:.*$/
            syntax match outputTimestamp /^Started at:.*$\|^Finished at:.*$/
            syntax match outputSeparator /^-\+$/
            syntax match outputSuccess /^Command completed with exit code: 0$/
            syntax match outputError /^Command completed with exit code: [^0]\+$/

            highlight link outputHeader Title
            highlight link outputTimestamp Comment
            highlight link outputSeparator Comment
            highlight link outputSuccess String
            highlight link outputError Error
          ]]

          vim.b.current_syntax = "output"
        end
      })
    '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>mc";
        action = ":CompileCommand<CR>";
        options = { silent = true; desc = "Set compile command"; };
      }

      {
        mode = "n";
        key = "<leader>mr";
        action = ":CompileRun<CR>";
        options = { silent = true; desc = "Run compile command"; };
      }

      {
        mode = "n";
        key = "<leader>md";
        action = ":CompileClear<CR>";
        options = { silent = true; desc = "Clear compile command"; };
      }

      {
        mode = "n";
        key = "<leader>mp";
        action = ":lua _G.browse_compile_history('prev')<CR>";
        options = { silent = true; desc = "Previous compile command"; };
      }

      {
        mode = "n";
        key = "<leader>mn";
        action = ":lua _G.browse_compile_history('next')<CR>";
        options = { silent = true; desc = "Next compile command"; };
      }

      {
        mode = "n";
        key = "<leader>mk";
        action = ":CompileKill<CR>";
        options = { silent = true; desc = "Kill compile process"; };
      }

      {
        mode = "n";
        key = "<leader>mh";
        action = ":lua _G.telescope_compile_history()<CR>";
        options = { silent = true; desc = "Search compile history"; };
      }
    ];
  };
}
