-- Telescope configuration and search functionality

-- Store last search term globally
_G.last_telescope_search = ""

-- Register the telescope regex toggle action and search history
local telescope = require('telescope')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-r>"] = function(prompt_bufnr)
          local picker = action_state.get_current_picker(prompt_bufnr)
          local current_args = picker.finder.vimgrep_arguments
          local has_fixed_strings = false
          
          -- Search for --fixed-strings in current args
          for _, arg in ipairs(current_args) do
            if arg == "--fixed-strings" then
              has_fixed_strings = true
              break
            end
          end
          
          -- Create new args table
          local new_args = {}
          for _, arg in ipairs(current_args) do
            if arg ~= "--fixed-strings" and arg ~= "--pcre2" then
              table.insert(new_args, arg)
            end
          end
          
          if has_fixed_strings then
            -- Switch to regex mode
            table.insert(new_args, "--pcre2")
            vim.notify("Search Mode: Regex")
          else
            -- Switch to literal mode
            table.insert(new_args, "--fixed-strings")
            vim.notify("Search Mode: Literal")
          end
          
          picker.finder.vimgrep_arguments = new_args
          actions.reload_results(prompt_bufnr)
        end,
        ["<C-s>"] = function(prompt_bufnr)
          -- Save current search term
          _G.last_telescope_search = action_state.get_current_line()
          vim.notify("Search saved: " .. _G.last_telescope_search)
        end,
        ["<C-x>"] = function(prompt_bufnr)
          -- Clear saved search term
          _G.last_telescope_search = ""
          vim.notify("Search history cleared")
        end
      }
    }
  }
})

-- Custom function to start live_grep with last search term
local function live_grep_with_last_search()
  if _G.last_telescope_search ~= "" then
    require('telescope.builtin').live_grep({
      default_text = _G.last_telescope_search
    })
  else
    require('telescope.builtin').live_grep()
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