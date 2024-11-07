{ ... }:
{
  programs.nixvim.keymaps = [
    # Diagnostic navigation
    {
      mode = "n";
      key = "]d";  # Next diagnostic
      action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
    }
    {
      mode = "n";
      key = "[d";  # Previous diagnostic
      action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
    }
    
    # LSP core functionality
    {
      mode = "n";
      key = "<F12>";  # Go to definition
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
    }
    {
      mode = "n";
      key = "K";  # Show hover information
      action = "<cmd>lua vim.lsp.buf.hover()<CR>";
    }
    {
      mode = "n";
      key = "<F2>";  # Rename symbol
      action = "<cmd>lua vim.lsp.buf.rename()<CR>";
    }
    
    # Leader-based LSP commands
    {
      mode = "n";
      key = "<leader>ca";  # Code actions
      action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
    }
    {
      mode = "n";
      key = "<leader>gr";  # Show references
      action = "<cmd>lua vim.lsp.buf.references()<CR>";
    }
    {
      mode = "n";
      key = "<leader>df";  # Show diagnostic in float
      action = "<cmd>lua vim.diagnostic.open_float()<CR>";
    }
    {
      mode = "n";
      key = "<leader>li";  # Show LSP info
      action = "<cmd>LspInfo<CR>";
    }
    
    # Telescope (Fuzzy Finding)
    {
      mode = "n";
      key = "<C-p>";  # Find files
      action = "<cmd>Telescope find_files<CR>";
    }
    {
      mode = "n";
      key = "<C-f>";  # Find in files (grep)
      action = "<cmd>Telescope live_grep<CR>";
    }
    {
      mode = "n";
      key = "<leader>ws";  # Workspace symbols
      action = "<cmd>Telescope lsp_workspace_symbols<CR>";
    }
    {
      mode = "n";
      key = "<leader>ds";  # Document symbols
      action = "<cmd>Telescope lsp_document_symbols<CR>";
    }
    
    # Diagnostics
    {
      mode = "n";
      key = "<leader>ld";  # List diagnostics
      action = "<cmd>Telescope diagnostics<CR>";
    }
    {
      mode = "n";
      key = "<leader>dw";  # Show diagnostics in location list
      action = "<cmd>lua vim.diagnostic.setloclist()<CR>";
    }
    
    # File navigation
    {
      mode = "n";
      key = "-";  # File explorer
      action = "<CMD>Oil<CR>";
    }
  ];
}