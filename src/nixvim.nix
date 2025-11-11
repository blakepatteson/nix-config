{ ... }:
let
  nixvim = import (builtins.fetchTarball {
    url = "https://github.com/nix-community/nixvim/archive/nixos-25.05.tar.gz";
    sha256 = "0mndx4dmysimmgl1gsa5kjdgha53w7wz26zv78fxva432qf7v61a";
  });
in
{
  imports = [
    nixvim.nixosModules.nixvim
    ./nixvim/autocmd.nix
    ./nixvim/extras.nix
    ./nixvim/keybinds.nix
    ./nixvim/plugins.nix
    ./nixvim/compile.nix
  ];

  programs.nixvim = {
    enable = true;
    opts = {
      autoindent = true;
      backup = false;
      clipboard = "unnamedplus";
      colorcolumn = [ "80" "90" ];
      expandtab = true;
      foldenable = true;
      foldexpr = "nvim_treesitter#foldexpr()";
      foldlevel = 99;
      foldmethod = "expr";
      ignorecase = true;
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      smartcase = true;
      smartindent = true;
      softtabstop = 2;
      swapfile = false;
      tabstop = 2;
      writebackup = false;
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

