{ ... }:
{
  programs.nixvim.keymaps = [
    # Diagnostic navigation
    {
      mode = "n";
      key = "]d"; # Next diagnostic
      action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
    }
    {
      mode = "n";
      key = "[d"; # Previous diagnostic
      action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
    }

    # LSP core functionality
    {
      mode = "n";
      key = "<F12>"; # Go to definition
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
    }
    {
      mode = "n";
      key = "K"; # Show hover information
      action = "<cmd>lua vim.lsp.buf.hover()<CR>";
    }
    {
      mode = "n";
      key = "<F2>"; # Rename symbol
      action = "<cmd>lua vim.lsp.buf.rename()<CR>";
    }

    # Leader-based LSP commands
    {
      mode = "n";
      key = "<leader>ca"; # Code actions
      action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
    }
    {
      mode = "n";
      key = "<leader>gr"; # Show references
      action = "<cmd>lua vim.lsp.buf.references()<CR>";
    }
    {
      mode = "n";
      key = "<leader>df"; # Show diagnostic in float
      action = "<cmd>lua vim.diagnostic.open_float()<CR>";
    }
    {
      mode = "n";
      key = "<leader>li"; # Show LSP info
      action = "<cmd>LspInfo<CR>";
    }

    # Telescope (Fuzzy Finding)
    {
      mode = "n";
      key = "<C-p>"; # Find files
      action = "<cmd>Telescope find_files<CR>";
    }
    {
      mode = "n";
      key = "<C-f>"; # Find in files (grep)
      action = "<cmd>Telescope live_grep<CR>";
    }
    {
      mode = "n";
      key = "<leader>ws"; # Workspace symbols
      action = "<cmd>Telescope lsp_workspace_symbols<CR>";
    }
    {
      mode = "n";
      key = "<leader>ds"; # Document symbols
      action = "<cmd>Telescope lsp_document_symbols<CR>";
    }

    # Diagnostics
    {
      mode = "n";
      key = "<leader>ld"; # List diagnostics
      action = "<cmd>Telescope diagnostics<CR>";
    }
    {
      mode = "n";
      key = "<leader>dw"; # Show diagnostics in location list
      action = "<cmd>lua vim.diagnostic.setloclist()<CR>";
    }

    # File navigation
    {
      mode = "n";
      key = "-"; # File explorer
      action = "<CMD>Oil<CR>";
    }
    # Quick save and quit
    {
      mode = "n";
      key = "<leader>w"; # Quick save
      action = ":w<CR>";
    }
    {
      mode = "n";
      key = "<leader>q"; # Quick quit
      action = ":q<CR>";
    }

    # VSCode-like line moving
    {
      mode = "v";
      key = "<M-j>"; # Move selected lines down
      action = ":m '>+1<CR>gv=gv";
    }
    {
      mode = "v";
      key = "<M-k>"; # Move selected lines up
      action = ":m '<-2<CR>gv=gv";
    }

    # Center view when navigating
    {
      mode = "n";
      key = "<C-d>"; # Scroll down and center
      action = "<C-d>zz";
    }
    {
      mode = "n";
      key = "<C-u>"; # Scroll up and center
      action = "<C-u>zz";
    }
    {
      mode = "n";
      key = "n"; # Next search result and center
      action = "nzzzv";
    }
    {
      mode = "n";
      key = "N"; # Previous search result and center
      action = "Nzzzv";
    }

    # Terminal
    {
      mode = "n";
      key = "<leader>t"; # Open terminal
      action = ":terminal<CR>";
    }

    # LSP additional
    {
      mode = "n";
      key = "<leader>fd"; # Find definition
      action = "<cmd>Telescope lsp_definitions<CR>";
    }
    {
      mode = "n";
      key = "<leader>fi"; # Find implementation
      action = "<cmd>Telescope lsp_implementations<CR>";
    }

    # Black hole delete (delete without yanking)
    {
      mode = "n";
      key = "<leader>d"; # Delete line without yanking
      action = "\"_dd";
    }
  ];
}

