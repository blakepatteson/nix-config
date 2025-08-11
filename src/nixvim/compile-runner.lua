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

-- Telescope picker for compile command history
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
        return { value = entry, display = entry, ordinal = entry, }
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
  
  -- Create output directory
  local output_dir = vim.fn.expand("~/.local/share/nvim/compile_outputs")
  vim.fn.mkdir(output_dir, "p")
  
  -- Generate filename with timestamp and sanitized command
  local timestamp = os.date("%Y%m%d_%H%M%S")
  local sanitized_cmd = string.gsub(_G.compile_command.command, "[^%w%-%.]", "_")
  local filename = timestamp .. "_" .. sanitized_cmd .. ".txt"
  local filepath = output_dir .. "/" .. filename
  
  -- Create a new buffer and set it to the actual file
  vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  local buf = vim.api.nvim_get_current_buf()
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
  vim.api.nvim_buf_set_option(buf, "swapfile", true)
  
  -- Prepare header content
  local header_lines = {
    "Running: " .. _G.compile_command.command,
    "Started at: " .. os.date("%Y-%m-%d %H:%M:%S"),
    "Working directory: " .. vim.fn.getcwd(),
    "Output saved to: " .. filepath,
    "------------------------------------------------------------",
    ""
  }
  
  -- Add header to buffer
  vim.api.nvim_buf_set_lines(buf, 0, 0, false, header_lines)
  
  -- Execute command and capture output
  local line_count = 6  -- Start after our header (updated count)
  local start_time = vim.loop.hrtime()  -- Capture high-resolution start time
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
              local line_num = line_count - #data + i - 1
              -- Add bounds check to prevent crash
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
      -- Calculate duration with high precision
      local end_time = vim.loop.hrtime()
      local duration_ns = end_time - start_time
      local duration_seconds = duration_ns / 1e9  -- Convert nanoseconds to seconds
      
      local duration_text
      if duration_seconds >= 60 then
        local minutes = math.floor(duration_seconds / 60)
        local seconds = duration_seconds % 60
        duration_text = string.format("%dm %.2fs", minutes, seconds)
      else
        duration_text = string.format("%.2fs", duration_seconds)
      end
      
      -- Footer lines for both buffer and file
      local footer_lines = {
        "",
        "------------------------------------------------------------",
        "Command completed with exit code: " .. exit_code,
        "Duration: " .. duration_text,
        "Finished at: " .. os.date("%Y-%m-%d %H:%M:%S")
      }
      
      -- Add footer to buffer
      vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, footer_lines)
      
      -- Save the buffer to disk
      vim.cmd("silent write!")
      
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
    on_exit = function(_, exit_code)
      -- Don't auto-close - keep the output visible
      -- Just switch to normal mode and set up keybindings
      vim.cmd("stopinsert")
      
      -- Set buffer local mappings for easy exit
      vim.api.nvim_buf_set_keymap(buf, "n", "q", ":bd<CR>", 
          {noremap = true, silent = true})
      vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":bd<CR>", 
          {noremap = true, silent = true})
    end
  })
end

-- Function to run git commit with proper editor behavior in current session
_G.run_git_commit = function()
  -- Check if we have any changes to commit
  local status_output = vim.fn.system("git status --porcelain")
  if vim.v.shell_error ~= 0 then
    vim.notify("Not in a git repository", vim.log.levels.ERROR)
    return
  end
  
  -- For commit -a, we don't need to check if there are staged changes,
  -- just if there are any modified files that can be committed
  local modified_files = vim.fn.system("git diff --name-only")
  if modified_files == "" then
    vim.notify("No changes to commit", vim.log.levels.WARN)
    return
  end
  
  -- Create new tab for commit message
  vim.cmd("tabnew")
  local buf = vim.api.nvim_get_current_buf()
  
  -- Set buffer name and options
  vim.api.nvim_buf_set_name(buf, "COMMIT_EDITMSG")
  vim.api.nvim_buf_set_option(buf, "filetype", "gitcommit")
  vim.api.nvim_buf_set_option(buf, "buftype", "acwrite")
  
  -- Get git status for the commit template
  local git_status = vim.fn.system("git status")
  
  -- Create commit message template
  local template_lines = {
    "",
    "# Please enter the commit message for your changes. Lines starting",
    "# with '#' will be ignored, and an empty message aborts the commit.",
    "#",
  }
  
  -- Add git status to template
  for line in git_status:gmatch("[^\r\n]+") do
    table.insert(template_lines, "# " .. line)
  end
  
  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, template_lines)
  
  -- Position cursor at the first line for message input
  vim.api.nvim_win_set_cursor(0, {1, 0})
  
  -- Set up autocmd to handle the commit when buffer is written
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local commit_msg_lines = {}
      
      -- Filter out comment lines and collect commit message
      for _, line in ipairs(lines) do
        if not line:match("^%s*#") then
          table.insert(commit_msg_lines, line)
        end
      end
      
      -- Remove trailing empty lines
      while #commit_msg_lines > 0 and commit_msg_lines[#commit_msg_lines]:match("^%s*$") do
        table.remove(commit_msg_lines)
      end
      
      -- Check if message is empty
      if #commit_msg_lines == 0 or (
         #commit_msg_lines == 1 and commit_msg_lines[1]:match("^%s*$")) then
        vim.notify("Empty commit message, aborting commit", vim.log.levels.WARN)
        return
      end
      
      -- Write message to temporary file
      local temp_file = vim.fn.tempname()
      vim.fn.writefile(commit_msg_lines, temp_file)
      
      -- Execute git commit
      local result = vim.fn.system("git commit -a --file=" .. temp_file)
      
      if vim.v.shell_error == 0 then
        vim.notify("Commit successful!", vim.log.levels.INFO)
        -- Close the commit message buffer
        vim.cmd("bd")
      else
        -- Check if the error is just "nothing to commit" (which can happen if files weren't staged)
        if result:match("nothing to commit") then
          vim.notify("Nothing to commit (working tree clean)", vim.log.levels.WARN)
        else
          vim.notify("Commit failed: " .. result, vim.log.levels.ERROR)
        end
      end
      
      -- Clean up temp file
      vim.fn.delete(temp_file)
    end
  })
  
  -- Also handle buffer closing without saving (abort commit)
  vim.api.nvim_create_autocmd({"BufUnload", "BufDelete"}, {
    buffer = buf,
    once = true,
    callback = function()
      -- Only show abort message if we haven't already committed
      if vim.api.nvim_buf_is_valid(buf) then
        vim.notify("Commit aborted", vim.log.levels.INFO)
      end
    end
  })
end

vim.api.nvim_create_user_command('CompileKill', function()
  if _G.compile_job_id then
    vim.fn.jobstop(_G.compile_job_id)
    vim.notify("Compile job killed")
    _G.compile_job_id = nil
  else
    vim.notify("No active compile job to kill", vim.log.levels.WARN)
  end
end, {})
