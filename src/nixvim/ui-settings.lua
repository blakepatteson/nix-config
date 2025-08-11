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
