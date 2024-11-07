{ pkgs, lib, ... }:
{
  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "]d"; # Next diagnostic
      action = "vim.diagnostic.goto_next";
    }
    {
      mode = "n";
      key = "[d"; # Previous diagnostic
      action = "vim.diagnostic.goto_prev";
    }
    {
      mode = "n";
      key = "<F12>"; # Go to definition
      action = "vim.lsp.buf.definition";
    }
    {
      mode = "n";
      key = "K"; # Show hover information
      action = "vim.lsp.buf.hover";
    }
    {
      mode = "n";
      key = "<F2>"; # Rename symbol
      action = "vim.lsp.buf.rename";
    }

    # Leader-based LSP commands
    {
      mode = "n";
      key = "<leader>ca"; # Code actions
      action = "vim.lsp.buf.code_action";
    }
    {
      mode = "n";
      key = "<leader>gr"; # Show references
      action = "vim.lsp.buf.references";
    }
    {
      mode = "n";
      key = "<leader>df"; # Show diagnostic in float
      action = "vim.diagnostic.open_float";
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
    {
      mode = "n";
      key = "<leader>ld"; # List diagnostics
      action = "<cmd>Telescope diagnostics<CR>";
    }
    {
      mode = "n";
      key = "<leader>la"; # List LSP actions
      action = "<cmd>Telescope lsp_code_actions<CR>"; # This is the correct command
    }
    {
      mode = "n";
      key = "<leader>la";
      action = "vim.lsp.buf.code_action"; # This is another way to show code actions
    }
    {
      mode = "n";
      key = "-";
      action = "<CMD>Oil<CR>";
    }
    {
      mode = "n";
      key = "<leader>dl";
      action = "<cmd>Telescope diagnostics<CR>"; # List all diagnostics
    }
    {
      mode = "n";
      key = "<leader>dw";
      action = "<cmd>lua vim.diagnostic.setloclist()<CR>"; # Show diagnostics in location list
    }
  ];
}
