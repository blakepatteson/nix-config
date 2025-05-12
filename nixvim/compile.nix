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
          prompt = "Compile Command: ",
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
            if data and #data > 0 and data[1] ~= "" then
              vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, data)
              line_count = line_count + #data
            end
          end,
          on_stderr = function(_, data)
            if data and #data > 0 and data[1] ~= "" then
              -- Add stderr data in red if possible
              vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, data)
              
              -- Highlight stderr lines as errors
              for i, line in ipairs(data) do
                if line ~= "" then
                  vim.api.nvim_buf_add_highlight(buf, -1, "Error",
                      line_count - #data + i - 1, 0, -1)
                end
              end
              
              line_count = line_count + #data
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
