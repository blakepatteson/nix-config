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
    ./nixvim/rewrap.nix
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
        base00 = "#000000"; # Background
        base01 = "#1c1c1c"; # Lighter background (status bars)
        base02 = "#4d4d4d"; # Selection background
        base03 = "#c1c1c1"; # Comments, invisibles
        base04 = "#b0b0b0"; # Dark foreground
        base05 = "#ffffff"; # Default foreground
        base06 = "#ffffff"; # Light foreground
        base07 = "#ffffff"; # Pure white text

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
  };
}

