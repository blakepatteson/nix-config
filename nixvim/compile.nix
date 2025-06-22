{ ... }:
{
  programs.nixvim = {
    extraConfigLua = ''
      _G.compile_job_id = nil
      -- Compile Command Functionality
      _G.compile_command = {
        command = "",
        history = {},
        history_index = 0,
        buffer_counter = 0  -- Counter to ensure unique buffer names
      }

      -- Function to jump to error location from compile output
      _G.jump_to_error = function()
        local line = vim.api.nvim_get_current_line()
        
        -- Define error patterns for different compilers/tools
        local patterns = {
          -- Go compiler errors: "filename.go:line:col: message"
          go = "([^:]+%.go):(%d+):(%d+):",
          -- Generic filename:line:col pattern
          generic = "([^:%s]+):(%d+):(%d+):",
          -- Simplified filename:line pattern  
          simple = "([^:%s]+):(%d+):",
          -- Rust compiler errors
          rust = "([^:]+%.rs):(%d+):(%d+):",
          -- C/C++ compiler errors
          c = "([^:]+%.[ch]p?p?):(%d+):(%d+):",
          -- Python errors
          python = 'File "([^"]+)", line (%d+)',
          -- Nix errors
          nix = "([^:]+%.nix):(%d+):(%d+):",
        }
        
        local file, line_num, col_num
        
        -- Try each pattern until we find a match
        for name, pattern in pairs(patterns) do
          file, line_num, col_num = line:match(pattern)
          if file then
            break
          end
        end
        
        -- If no match found, try to extract just filename:line
        if not file then
          file, line_num = line:match("([^:%s]+):(%d+)")
        end
        
        if not file or not line_num then
          vim.notify("No file location found on current line", vim.log.levels.WARN)
          return
        end
        
        -- Convert to numbers
        line_num = tonumber(line_num)
        col_num = tonumber(col_num) or 1
        
        -- Check if file exists (try relative to current working directory first)
        local file_path = file
        if vim.fn.filereadable(file_path) == 0 then
          -- Try absolute path
          if not file:match("^/") then
            -- Try some common relative paths
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
        
        -- Check if file exists
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
        
        -- vim.notify(string.format("Jumped to %s:%d:%d", file, line_num, col_num))
      end

      -- Function to prompt for compile command
      _G.prompt_compile_command = function()
        -- Save the current command if history index is at current command
        if _G.compile_command.history_index == 0 and _G.compile_command.command ~= "" then
          table.insert(_G.compile_command.history, 1, _G.compile_command.command)
          if #_G.compile_command.history > 50 then
            table.remove(_G.compile_command.history)
          end
        end
        
        -- Prompt for command with existing as default
        local input_command = vim.fn.input({
          prompt = "Compile > ",
          default = _G.compile_command.command,
          completion = "shellcmd"
        })
        
        -- Update command if changed
        if input_command ~= "" then
          _G.compile_command.command = input_command
          -- Add to history if not already at the top
          if #_G.compile_command.history == 0 or _G.compile_command.history[1] ~= 
            input_command then
            table.insert(_G.compile_command.history, 1, input_command)
            if #_G.compile_command.history > 50 then
              table.remove(_G.compile_command.history)
            end
          end
          _G.compile_command.history_index = 0
        end
        
        return input_command ~= ""
      end

      -- Function to browse command history
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
          _G.compile_command.command = _G.compile_command.history[
          _G.compile_command.history_index]
        end
        
      end

      _G.clear_compile_command = function()
        _G.compile_command.command = ""
        _G.compile_command.history_index = 0
        vim.notify("Compile command cleared", vim.log.levels.INFO)
      end

      -- Add this user command after the other user commands
      vim.api.nvim_create_user_command('CompileClear', function()
        _G.clear_compile_command()
      end, {})

      -- Function to run compile command and capture output in buffer
      _G.run_compile_command = function()
        -- If no command set, prompt for one
        if _G.compile_command.command == "" then
          if not _G.prompt_compile_command() then
            return
          end
        end
        
        -- Increment buffer counter for unique names
        _G.compile_command.buffer_counter = _G.compile_command.buffer_counter + 1
        
        -- Create a new buffer
        vim.cmd("enew")
        local buf = vim.api.nvim_get_current_buf()
        
        -- Set buffer options for a scratch buffer
        vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
        vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
        vim.api.nvim_buf_set_option(buf, "swapfile", false)
        
        -- Set a unique buffer name
        local bufname = "Output_" .. _G.compile_command.buffer_counter .. "_" .. 
                       string.gsub(_G.compile_command.command, "[^%w]", "_")
        vim.api.nvim_buf_set_name(buf, bufname)
        
        -- Add header to buffer
        vim.api.nvim_buf_set_lines(buf, 0, 0, false, {
          "Running: " .. _G.compile_command.command,
          "Started at: " .. os.date("%Y-%m-%d %H:%M:%S"),
          "------------------------------------------------------------",
          ""
        })
        
        -- Execute command and capture output
        local line_count = 4  -- Start after our header
        local cmd = vim.fn.jobstart(_G.compile_command.command, {
          on_stdout = function(_, data)
            if data then
              -- Filter out the last empty string if present (indicates complete line)
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
              -- Filter out the last empty string if present
              if #data > 1 and data[#data] == "" then
                table.remove(data)
              end
              
              if #data > 0 then
                vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, data)
                
                -- Highlight stderr lines as errors (skip empty lines for highlighting)
                for i, line in ipairs(data) do
                  if line ~= "" then
                    vim.api.nvim_buf_add_highlight(buf, -1, "Error",
                        line_count - #data + i - 1, 0, -1)
                  end
                end
                
                line_count = line_count + #data
              end
            end
          end,
          on_exit = function(_, exit_code)
            -- Add footer with exit code
            vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, {
              "",
              "------------------------------------------------------------",
              "Command completed with exit code: " .. exit_code,
              "Finished at: " .. os.date("%Y-%m-%d %H:%M:%S")
            })
            
            -- Set buffer local mappings
            vim.api.nvim_buf_set_keymap(buf, "n", "q", ":bd<CR>", 
                {noremap = true, silent = true})
            vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":bd<CR>", 
                {noremap = true, silent = true})
            vim.api.nvim_buf_set_keymap(buf, "n", "r", ":lua _G.run_compile_command()<CR>", 
                {noremap = true, silent = true, desc = "Run command again"})
            vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", ":lua _G.jump_to_error()<CR>", 
                {noremap = true, silent = true, desc = "Jump to error location"})
            vim.api.nvim_buf_set_keymap(buf, "n", "gf", ":lua _G.jump_to_error()<CR>", 
                {noremap = true, silent = true, desc = "Jump to error location"})
            
            -- Set the filetype for syntax highlighting if possible
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

     
      -- Command to set the compile command
      vim.api.nvim_create_user_command('CompileCommand', function()
        _G.prompt_compile_command()
      end, {})
      
      -- Command to run the compile command
      vim.api.nvim_create_user_command('CompileRun', function()
        _G.run_compile_command()
      end, {})
      
      -- Optional: Function to check if in a nix shell and load environment
      local function ensure_nix_shell()
        -- Check if we're in a directory with a shell.nix or default.nix
        local has_nix = vim.fn.filereadable("shell.nix") == 1 or 
            vim.fn.filereadable("default.nix") == 1
      end
      
      -- Command to enter nix shell in a new terminal
      vim.api.nvim_create_user_command('NixShell', function()
        vim.cmd("botright new")
        vim.cmd("resize " .. vim.o.lines)
        vim.fn.termopen("nix-shell", {
          on_exit = function(_, _)
            vim.cmd("q")
          end
        })
        vim.cmd("startinsert")
      end, {})
      
      -- Create a custom output filetype for syntax highlighting
      vim.api.nvim_create_autocmd({"BufEnter", "BufNew"}, {
        pattern = "Output_*",
        callback = function()
          -- Check if syntax is already set
          if vim.b.current_syntax then
            return
          end
          
          -- Basic syntax highlighting for command output
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
          
          -- Set the syntax name
          vim.b.current_syntax = "output"
        end
      })
      
      -- Auto check for nix shell on buffer enter
      vim.api.nvim_create_autocmd({"BufEnter", "DirChanged"}, {
        pattern = "*",
        callback = ensure_nix_shell
      })

      vim.api.nvim_create_user_command('CompileKill', function()
        if _G.compile_job_id then
          vim.fn.jobstop(_G.compile_job_id)
          vim.notify("Compile job killed")
          _G.compile_job_id = nil
        else
          vim.notify("No active compile job to kill", vim.log.levels.WARN)
        end
      end, {})
    '';

    keymaps = [
      # Set compile command
      {
        mode = "n";
        key = "<leader>mc";
        action = ":CompileCommand<CR>";
        options = {
          silent = true;
          desc = "Set compile command";
        };
      }

      # Run compile command
      {
        mode = "n";
        key = "<leader>mr";
        action = ":CompileRun<CR>";
        options = {
          silent = true;
          desc = "Run compile command";
        };
      }

      {
        mode = "n";
        key = "<leader>md";
        action = ":CompileClear<CR>";
        options = {
          silent = true;
          desc = "Clear compile command";
        };
      }

      # Previous compile command from history
      {
        mode = "n";
        key = "<leader>mp";
        action = ":lua _G.browse_compile_history('prev')<CR>";
        options = {
          silent = true;
          desc = "Previous compile command";
        };
      }

      # Next compile command from history
      {
        mode = "n";
        key = "<leader>mn";
        action = ":lua _G.browse_compile_history('next')<CR>";
        options = {
          silent = true;
          desc = "Next compile command";
        };
      }

      {
        mode = "n";
        key = "<leader>mk";
        action = ":CompileKill<CR>";
        options = {
          silent = true;
          desc = "Kill compile process";
        };
      }

      # Enter nix shell
      {
        mode = "n";
        key = "<leader>ms";
        action = ":NixShell<CR>";
        options = {
          silent = true;
          desc = "Enter nix shell";
        };
      }
    ];
  };
}
