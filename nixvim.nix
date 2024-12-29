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
      foldmethod = "expr";
      foldexpr = "nvim_treesitter#foldexpr()";
      foldenable = true;
      foldlevel = 99;
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
      settings = { ts_rainbow = true; lsp_semantic = true; };
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
      CP = {
        command = /* lua */ ''
          lua local oil = require('oil'); 
              local entry = oil.get_cursor_entry(); 
              if entry and entry.name then 
                local path = oil.get_current_dir() .. '/' .. entry.name; 
                vim.fn.setreg('+', path); 
                vim.notify('Copied: ' .. path) 
              else 
                vim.notify('No file under cursor', vim.log.levels.WARN) 
              end
        '';
        desc = "Copy full path of file under cursor";
      };
    };
  };
}


