{ pkgs, lib, ... }:
let
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
    # If you are not running an unstable channel of nixpkgs, select the corresponding branch of nixvim.
    # ref = "nixos-23.11";
  });
in
{
  imports = [
    nixvim.nixosModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    
    # Enable clipboard support
    clipboard.providers.xclip.enable = true;
    clipboard.register = "unnamedplus";

    # Plugins
    plugins = {
      telescope.enable = true;
      lualine.enable = true;
      web-devicons.enable = true;
      # nvim-tree.enable = true;  # File explorer
      # treesitter.enable = true; # Better syntax highlighting
    };

    # Colorscheme
    colorschemes.onedark.enable = true;

    # Basic keymaps for Telescope and other functionalities
    extraConfigVim = ''
      " Telescope keymaps
      nnoremap <leader>ff <cmd>Telescope find_files<CR>
      nnoremap <leader>fg <cmd>Telescope live_grep<CR>
      nnoremap <leader>fb <cmd>Telescope buffers<CR>
      nnoremap <leader>fh <cmd>Telescope help_tags<CR>

      " Clipboard keymaps
      nnoremap <leader>y "+y
      vnoremap <leader>y "+y
      nnoremap <leader>p "+p
      vnoremap <leader>p "+p

      " NvimTree keymap
      nnoremap <C-n> :NvimTreeToggle<CR>
      " nvim-tree.enable = true;  # File explorer
      " nvim-tree.enable = true;  # File explorer
      " nvim-tree.enable = true;  # File explorer
      " nvim-tree.enable = true;  # File explorer

      " Set clipboard to use system clipboard
      set clipboard+=unnamedplus
    '';

    # Global options
    globals.mapleader = " "; # Set leader key to space
  };
}
