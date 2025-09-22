{ ... }:

{
  programs.nixvim.keymaps = [
    { mode = "n"; key = "]d"; action = "<cmd>lua vim.diagnostic.goto_next()<CR>"; }
    { mode = "n"; key = "[d"; action = "<cmd>lua vim.diagnostic.goto_prev()<CR>"; }

    {
      mode = "n";
      key = "<leader>vb";
      action = "<C-v>";
      options = { desc = "Enter visual block mode"; };
    }

    {
      mode = "n";
      key = "<C-z>";
      action = "<C-v>";
      options = { desc = "Enter visual block mode (alternative)"; };
    }


    {
      mode = "v";
      key = "<C-z>";
      action = "<C-v>";
      options = { desc = "Enter visual block mode (alternative)"; };
    }

    {
      mode = "n";
      key = "]r";
      action =
        "<cmd>lua require('telescope.builtin').lsp_references({jump_type='never'})<CR>";
    }
    {
      mode = "n";
      key = "[r";
      action =
        "<cmd>lua require('telescope.builtin').lsp_references({jump_type='never'})<CR>";
    }

    {
      mode = "n";
      key = "]h";
      action = "<cmd>lua require('gitsigns').next_hunk()<CR>";
    }
    {
      mode = "n";
      key = "[h";
      action = "<cmd>lua require('gitsigns').prev_hunk()<CR>";
    }
    { mode = "n"; key = "]H"; action = "<cmd>NextGitFile<CR>"; }
    { mode = "n"; key = "[H"; action = "<cmd>PrevGitFile<CR>"; }

    { mode = "n"; key = "<leader>rh"; action = "<cmd>Gitsigns reset_hunk<CR>"; }
    { mode = "n"; key = "<leader>rb"; action = "<cmd>Gitsigns reset_buffer<CR>"; }

    {
      mode = "n";
      key = "<leader>gB";
      action = "<cmd>Gitsigns blame_line<CR>";
      options = { desc = "Show git blame for current line"; };
    }
    {
      mode = "n";
      key = "<leader>gt";
      action = "<cmd>Gitsigns toggle_current_line_blame<CR>";
      options = { desc = "Toggle git blame virtual text"; };
    }

    {
      mode = "n";
      key = "<leader>gs";
      action = "<cmd>lua _G.run_git_command('git status')<CR>";
    }
    {
      mode = "n";
      key = "<leader>gb";
      action = "<cmd>lua _G.run_git_command('git branch -vva')<CR>";
    }
    {
      mode = "n";
      key = "<leader>gD";
      action = "<cmd>lua _G.run_git_command('git --no-pager diff', 'vsplit')<CR>";
    }
    {
      mode = "n";
      key = "<leader>gT";
      action = "<cmd>lua _G.run_git_command('git --no-pager diff', 'tab')<CR>";
    }
    {
      mode = "n";
      key = "<leader>gc";
      action = "<cmd>lua _G.smart_git_commit()<CR>";
    }
    {
      mode = "n";
      key = "<leader>ca";
      action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
    }
    {
      mode = "v";
      key = "<leader>ca";
      action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
    }
    {
      mode = "n";
      key = "<leader>gr";
      action = "<cmd>lua vim.lsp.buf.references()<CR>";
    }
    {
      mode = "n";
      key = "<leader>df";
      action = "<cmd>lua vim.diagnostic.open_float()<CR>";
    }
    {
      mode = "n";
      key = "<leader>li";
      action = "<cmd>LspInfo<CR>";
    }
    {
      mode = "n";
      key = "<leader>gh";
      action = "<cmd>WorkspaceGitHunks<CR>";
    }
    {
      mode = "n";
      key = "<leader>rn";
      action = "<cmd>lua vim.lsp.buf.rename()<CR>";
    }
    {
      mode = "n";
      key = "<leader>gd";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
    }
    {
      mode = "n";
      key = "<leader>fm";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
    }
    {
      mode = "n";
      key = "<leader>bd";
      action = "<cmd>bd<CR>";
    }
    {
      mode = "n";
      key = "<leader>bk";
      action = "<cmd>bd!<CR>";
    }
    {
      mode = "n";
      key = "<F2>";
      action = "<cmd>lua vim.lsp.buf.rename()<CR>";
    }
    {
      mode = "n";
      key = "<F12>";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
    }
    {
      mode = "n";
      key = "<C-n>";
      action = "<cmd>enew<CR>";
    }
    {
      mode = "n";
      key = "<C-w>";
      action = "<cmd>lua vim.cmd('bd')<CR>";
      options = { desc = "Close buffer instantly"; nowait = true; };
    }

    # Telescope (Fuzzy Finding)
    { mode = "n"; key = "<C-p>"; action = "<cmd>Telescope find_files<CR>"; }
    { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<CR>"; }
    {
      mode = "n";
      key = "<C-f>";
      action = "<cmd>lua _G.live_grep_with_last_search()<CR>";
    }
    {
      mode = "n";
      key = "<C-g>";
      action = "<cmd>lua _G.live_grep_regex()<CR>";
    }
    { mode = "n"; key = "<leader>fg"; action = "<cmd>Telescope live_grep<CR>"; }
    { mode = "n"; key = "<leader>sr"; action = "<cmd>lua _G.live_grep_regex()<CR>"; }
    {
      mode = "n";
      key = "<leader>fr";
      action = "<cmd>lua _G.resume_last_telescope()<CR>";
    }
    {
      mode = "n";
      key = "<leader>fc";
      action = "<cmd>lua _G.clear_telescope_search()<CR>";
    }
    {
      mode = "n";
      key = "<leader>ws";
      action = "<cmd>Telescope lsp_workspace_symbols<CR>";
    }
    {
      mode = "n";
      key = "<leader>ds";
      action = "<cmd>Telescope lsp_document_symbols<CR>";
    }
    { mode = "n"; key = "<leader>re"; action = "<cmd>Telescope oldfiles<CR>"; }

    # Diagnostics
    { mode = "n"; key = "<leader>ld"; action = "<cmd>Telescope diagnostics<CR>"; }
    {
      mode = "n";
      key = "<leader>dw";
      action = "<cmd>lua vim.diagnostic.setloclist()<CR>";
    }
    { mode = "n"; key = "-"; action = "<CMD>Oil<CR>"; }

    # buffer movement
    { mode = "n"; key = "<Tab>"; action = "<cmd>bn<CR>"; }
    { mode = "n"; key = "<S-Tab>"; action = "<cmd>bp<CR>"; }

    # VSCode-like line moving
    { mode = "v"; key = "<M-j>"; action = ":m '>+1<CR>gv=gv"; }
    { mode = "v"; key = "<M-k>"; action = ":m '<-2<CR>gv=gv"; }

    # Indentation in visual mode
    { mode = "v"; key = "<Tab>"; action = ">gv"; }
    { mode = "v"; key = "<S-Tab>"; action = "<gv"; }

    # Center view when navigating
    { mode = "n"; key = "<C-d>"; action = "<C-d>zz"; }
    { mode = "n"; key = "<C-u>"; action = "<C-u>zz"; }
    { mode = "n"; key = "n"; action = "nzzzv"; }
    { mode = "n"; key = "N"; action = "Nzzzv"; }

    # Window navigation (since <C-w> is remapped to close)
    { mode = "n"; key = "<C-h>"; action = "<C-w>h"; }
    { mode = "n"; key = "<C-j>"; action = "<C-w>j"; }
    { mode = "n"; key = "<C-k>"; action = "<C-w>k"; }
    { mode = "n"; key = "<M-l>"; action = "<C-w>l"; }

    # Window resizing
    { mode = "n"; key = "<C-Left>"; action = "<C-w><"; }
    { mode = "n"; key = "<C-Right>"; action = "<C-w>>"; }
    { mode = "n"; key = "<C-Up>"; action = "<C-w>+"; }
    { mode = "n"; key = "<C-Down>"; action = "<C-w>-"; }
    {
      mode = "n";
      key = "<leader>wo";
      action = "<C-w>o";
      options = { desc = "Close all other windows"; };
    }
    {
      mode = "n";
      key = "<leader>ww";
      action = "<C-w>w";
      options = { desc = "Cycle between windows"; };
    }

    # LSP additional
    { mode = "n"; key = "<leader>fd"; action = "<cmd>Telescope lsp_definitions<CR>"; }
    { mode = "n"; key = "<leader>fi"; action = "<cmd>Telescope lsp_implementations<CR>"; }

    {
      mode = "n";
      key = "<leader>cp";
      action = "<cmd>lua _G.copy_oil_file_path()<CR>";
    }

    # Black hole delete (delete without yanking)
    { mode = "n"; key = "d"; action = "\"_d"; }
    { mode = "n"; key = "D"; action = "\"_D"; }
    { mode = "n"; key = "dd"; action = "\"_dd"; }
    { mode = "v"; key = "d"; action = "\"_d"; }
    { mode = "x"; key = "d"; action = "\"_d"; }
    { mode = "v"; key = "p"; action = "\"_dP"; }
    { mode = "x"; key = "p"; action = "\"_dP"; }

  ];
}

