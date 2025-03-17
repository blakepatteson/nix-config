{ ... }:
{
  programs.nixvim = {
    # Add formatexpr for proper rewrapping support
    opts.formatexpr = "v:lua.require('conform').formatexpr()";

    # Add the conform.nvim formatter plugin
    plugins.conform-nvim = {
      enable = true;
      # formatOnSave = false; # Don't format on save unless explicitly set
      settings = {
        formatters_by_ft = {
          "*" = [ "trim_whitespace" ]; # Default formatter for all file types
        };
      };
    };

    # Add text wrapping keybindings
    keymaps = [
      # Alt+Q to rewrap current paragraph with custom function
      {
        mode = "n";
        key = "<M-q>";
        action = ":ReformatClean<CR>"; # Use our custom clean reformatter
        options = {
          silent = true;
          desc = "Rewrap paragraph cleanly at textwidth";
        };
      }

      # Visual mode rewrap with custom function
      {
        mode = "v";
        key = "<M-q>";
        action = ":ReformatClean<CR>";
        options = {
          silent = true;
          desc = "Rewrap selected text cleanly at textwidth";
        };
      }

      # Original gw-based rewrap (as fallback)
      {
        mode = "n";
        key = "<leader>rw";
        action = "gwip";
        options = {
          silent = true;
          desc = "Rewrap paragraph using Vim's gw";
        };
      }

      # Custom 80-column rewrap
      {
        mode = "n";
        key = "<leader>r8";
        action = ":set textwidth=80<CR>:ReformatClean<CR>:set textwidth=0<CR>";
        options = {
          silent = true;
          desc = "Rewrap paragraph cleanly at 80 columns";
        };
      }
    ];

    # Set up autocommands for specific file types
    autoCmd = [
      {
        event = [ "FileType" ];
        pattern = [ "markdown" "text" "mail" "tex" "rst" ];
        command = "setlocal textwidth=80"; # Set 80 columns for these text-heavy formats
      }
    ];

    # Add extra configuration for rewrap behavior
    extraConfigLua = ''
      -- Default settings for text formatting
      vim.opt.formatoptions = vim.opt.formatoptions
        + "q"   -- Allow formatting of comments with gq
        - "n"   -- Don't recognize numbered lists (prevents unwanted indentation)
        + "1"   -- Don't break a line after a one-letter word
        + "j"   -- Remove comment leader when joining lines
        - "t"   -- Don't auto-wrap text using textwidth
        - "c"   -- Don't auto-wrap comments using textwidth
        + "2"   -- Use indent of second line for entire paragraph
        - "a"   -- Don't auto-format paragraphs
        - "w"   -- Don't use trailing whitespace to indicate continuation

      -- Long line wrapping hint with ColorColumn
      vim.opt.colorcolumn = {"80", "90" }
      
      -- Custom function for cleaner paragraph reformatting
      function CleanReformat()
        -- Save cursor position
        local curpos = vim.fn.getcurpos()
        
        -- Get paragraph text and remove existing indentation
        local start_line = vim.fn.search([[^\s*$]], "bcnW") + 1
        local end_line = vim.fn.search([[^\s*$]], "nW") - 1
        if start_line > end_line then
          start_line = vim.fn.line('.')
          end_line = vim.fn.line('.')
        end
        
        local lines = vim.fn.getline(start_line, end_line)
        local text = table.concat(lines, " ")
        
        -- Remove multiple spaces
        text = text:gsub("%s+", " ")
        
        -- Split into wrapped lines based on textwidth
        local textwidth = vim.o.textwidth
        if textwidth == 0 then textwidth = 80 end
        
        local wrapped_lines = {}
        while #text > 0 do
          if #text <= textwidth then
            table.insert(wrapped_lines, text)
            break
          end
          
          local break_pos = textwidth
          while break_pos > 0 and text:sub(break_pos, break_pos) ~= " " do
            break_pos = break_pos - 1
          end
          
          if break_pos == 0 then
            -- If no space found, force break at textwidth
            break_pos = textwidth
          end
          
          table.insert(wrapped_lines, text:sub(1, break_pos))
          text = text:sub(break_pos + 1)
          
          -- Trim leading space if present
          text = text:gsub("^%s+", "")
        end
        
        -- Replace the paragraph
        vim.fn.deletebufline(vim.fn.bufnr(), start_line, end_line)
        vim.fn.append(start_line - 1, wrapped_lines)
        
        -- Restore cursor position
        vim.fn.setpos('.', curpos)
      end
      
      -- Command to call the custom function
      vim.api.nvim_create_user_command('ReformatClean', function()
        CleanReformat()
      end, {})
    '';
  };
}
