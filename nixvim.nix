{ pkgs, ... }:
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
    package = pkgs.neovim-unwrapped;
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
    globals = {
      mapleader = " ";
      VM_mouse_mappings = 1;
      VM_maps = { "Find Under" = "<C-m>"; "Find Subword Under" = "<C-m>"; };
    };
    colorschemes.base16 = {
      enable = true;
      settings = {
        ts_rainbow = true;
        lsp_semantic = true;
      };
      colorscheme = {
        # Pure black background
        base00 = "#000000"; # Background
        base01 = "#1c1c1c"; # Lighter background (status bars)
        base02 = "#4d4d4d"; # Selection background
        base03 = "#c1c1c1"; # Comments, invisibles
        base04 = "#b0b0b0"; # Dark foreground
        base05 = "#d0d0d0"; # Default foreground
        base06 = "#e0e0e0"; # Light foreground
        base07 = "#f5f5f5"; # Light background
        # Vibrant colors for syntax
        base08 = "#ff5555"; # Red -       Variables
        base09 = "#ff9955"; # Orange -    Integers, Boolean
        base0A = "#ffff55"; # Yellow -    Classes
        base0B = "#55ff55"; # Green -     Strings
        base0C = "#55ffff"; # Aqua -      Support
        base0D = "#5555ff"; # Blue -      Functions
        base0E = "#ff55ff"; # Purple -    Keywords
        base0F = "#ff5555"; # Red (alt) - Deprecated
      };
    };
    userCommands = {
      CA = { command = "lua vim.lsp.buf.code_action()"; desc = "Code actions"; };
      F = { command = "lua vim.lsp.buf.format()"; desc = "Format document"; };
      RN = { command = "lua vim.lsp.buf.rename()"; desc = "Rename symbol"; };
      H = { command = "lua vim.lsp.buf.hover()"; desc = "Show hover info"; };
      D = { command = "lua vim.lsp.buf.definition()"; desc = "Go to definition"; };
      REF = { command = "lua vim.lsp.buf.references()"; desc = "Find references"; };

      FF = { command = "Telescope find_files"; desc = "Find files"; };
      FG = { command = "Telescope live_grep"; desc = "Find in files"; };
      FB = { command = "Telescope buffers"; desc = "Find buffers"; };
      FH = { command = "Telescope help_tags"; desc = "Search help"; };
      FS = { command = "Telescope lsp_document_symbols"; desc = "Find symbols"; };

      # Diagnostic commands
      DL = { command = "Telescope diagnostics"; desc = "List all diagnostics"; };
      DF = { command = "lua vim.diagnostic.open_float()"; desc = "Show diagnostic float"; };
      DN = { command = "lua vim.diagnostic.goto_next()"; desc = "Next diagnostic"; };
      DP = { command = "lua vim.diagnostic.goto_prev()"; desc = "Previous diagnostic"; };

      CP = {
        command = ''
        lua vim.fn.setreg('+', require('oil').get_current_dir()
        require('oil').get_cursor_entry().name)
        '';
        desc = "Copy full path of file under cursor";
      };
    };
  };
}
