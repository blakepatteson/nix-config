{ ... }:
{
  programs.nixvim.keymaps = [
    # Diagnostic navigation
    { mode = "n"; key = "]d"; action = "<cmd>lua vim.diagnostic.goto_next()<CR>"; }
    { mode = "n"; key = "[d"; action = "<cmd>lua vim.diagnostic.goto_prev()<CR>"; }

    # cycle through lsp references navigation
    {
      mode = "n";
      key = "]r";
      action = "<cmd>lua require('telescope.builtin').lsp_references({jump_type='never'})<CR>";
    }
    {
      mode = "n";
      key = "[r";
      action = "<cmd>lua require('telescope.builtin').lsp_references({jump_type='never'})<CR>";
    }

    # Git navigation - both file and workspace level
    { mode = "n"; key = "]h"; action = "<cmd>lua require('gitsigns').next_hunk()<CR>"; }
    { mode = "n"; key = "[h"; action = "<cmd>lua require('gitsigns').prev_hunk()<CR>"; }
    { mode = "n"; key = "]H"; action = "<cmd>NextGitFile<CR>"; }
    { mode = "n"; key = "[H"; action = "<cmd>PrevGitFile<CR>"; }

    { mode = "n"; key = "<F12>"; action = "<cmd>lua vim.lsp.buf.definition()<CR>"; }
    { mode = "n"; key = "K"; action = "<cmd>lua vim.lsp.buf.hover()<CR>"; }
    { mode = "n"; key = "<F2>"; action = "<cmd>lua vim.lsp.buf.rename()<CR>"; }
    { mode = "v"; key = "M-r"; action = "<cmd>lua vim.lsp.buf.code_action()<CR>"; }
    { mode = "v"; key = "M-R"; action = "<cmd>lua vim.lsp.buf.code_action()<CR>"; }

    # Leader-based LSP commands
    { mode = "n"; key = "<leader>ca"; action = "<cmd>lua vim.lsp.buf.code_action()<CR>"; }
    { mode = "n"; key = "<leader>gr"; action = "<cmd>lua vim.lsp.buf.references()<CR>"; }
    { mode = "n"; key = "<leader>df"; action = "<cmd>lua vim.diagnostic.open_float()<CR>"; }
    { mode = "n"; key = "<leader>li"; action = "<cmd>LspInfo<CR>"; }
    { mode = "n"; key = "<leader>gh"; action = "<cmd>WorkspaceGitHunks<CR>"; }




    # Telescope (Fuzzy Finding)
    { mode = "n"; key = "<C-p>"; action = "<cmd>Telescope find_files<CR>"; }
    { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<CR>"; }
    { mode = "n"; key = "<C-f>"; action = "<cmd>Telescope live_grep<CR>"; }
    { mode = "n"; key = "<leader>ws"; action = "<cmd>Telescope lsp_workspace_symbols<CR>"; }
    { mode = "n"; key = "<leader>ds"; action = "<cmd>Telescope lsp_document_symbols<CR>"; }

    # Diagnostics
    { mode = "n"; key = "<leader>ld"; action = "<cmd>Telescope diagnostics<CR>"; }
    { mode = "n"; key = "<leader>dw"; action = "<cmd>lua vim.diagnostic.setloclist()<CR>"; }
    { mode = "n"; key = "-"; action = "<CMD>Oil<CR>"; }

    # buffer movement
    { mode = "n"; key = "<Tab>"; action = "<cmd>bn<CR>"; }

    # VSCode-like line moving
    { mode = "v"; key = "<M-j>"; action = ":m '>+1<CR>gv=gv"; }
    { mode = "v"; key = "<M-k>"; action = ":m '<-2<CR>gv=gv"; }

    # Center view when navigating
    { mode = "n"; key = "<C-d>"; action = "<C-d>zz"; }
    { mode = "n"; key = "<C-u>"; action = "<C-u>zz"; }
    { mode = "n"; key = "n"; action = "nzzzv"; }
    { mode = "n"; key = "N"; action = "Nzzzv"; }

    # Terminal
    { mode = "n"; key = "<leader>t"; action = ":terminal<CR>"; }

    # LSP additional
    { mode = "n"; key = "<leader>fd"; action = "<cmd>Telescope lsp_definitions<CR>"; }
    { mode = "n"; key = "<leader>fi"; action = "<cmd>Telescope lsp_implementations<CR>"; }

    # Black hole delete (delete without yanking)
    { mode = "n"; key = "<leader>d"; action = "\"_dd"; }
  ];
}

