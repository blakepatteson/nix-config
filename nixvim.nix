{ ... }:
let
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
  });
in
{
  imports = [
    nixvim.nixosModules.nixvim
    ./nixvim/autocmd.nix
    ./nixvim/extras.nix
    ./nixvim/keybinds.nix
    ./nixvim/plugins.nix
  ];
  programs.nixvim = {
    enable = true;
    globals = {
      mapleader = " ";
      VM_mouse_mappings = 1;
      VM_maps = {
        "Find Under" = "<C-m>";
        "Find Subword Under" = "<C-m>";
      };
    };
    # User commands are defined here
    userCommands = {
      CA = {
        command = "lua vim.lsp.buf.code_action()";
        desc = "Code actions";
      };
      F = {
        command = "lua vim.lsp.buf.format()";
        desc = "Format document";
      };
      RN = {
        command = "lua vim.lsp.buf.rename()";
        desc = "Rename symbol";
      };
      H = {
        command = "lua vim.lsp.buf.hover()";
        desc = "Show hover info";
      };
      D = {
        command = "lua vim.lsp.buf.definition()";
        desc = "Go to definition";
      };
      REF = {
        command = "lua vim.lsp.buf.references()";
        desc = "Find references";
      };

      # Telescope shortcuts
      FF = {
        command = "Telescope find_files";
        desc = "Find files";
      };
      FG = {
        command = "Telescope live_grep";
        desc = "Find in files";
      };
      FB = {
        command = "Telescope buffers";
        desc = "Find buffers";
      };
      FH = {
        command = "Telescope help_tags";
        desc = "Search help";
      };
      FS = {
        command = "Telescope lsp_document_symbols";
        desc = "Find symbols";
      };

      # Diagnostic commands
      DL = {
        command = "Telescope diagnostics";
        desc = "List all diagnostics";
      };
      DF = {
        command = "lua vim.diagnostic.open_float()";
        desc = "Show diagnostic float";
      };
      DN = {
        command = "lua vim.diagnostic.goto_next()";
        desc = "Next diagnostic";
      };
      DP = {
        command = "lua vim.diagnostic.goto_prev()";
        desc = "Previous diagnostic";
      };
    };
    opts = {
      number = true;
      relativenumber = true;
      clipboard = "unnamedplus";
      swapfile = false;
      backup = false;
      writebackup = false;
      colorcolumn = [ "80" "90" ];
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;
      autoindent = true;
      smartindent = true;
    };
  };
}
