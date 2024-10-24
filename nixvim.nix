{ pkgs, lib, ... }:
let
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
  });
in
{
  imports = [
    nixvim.nixosModules.nixvim
  ];
  programs.nixvim = {
    config = {
      enable = true;
      opts= {
        number = true;
        relativenumber = true;
        clipboard = "unnamedplus";
      };
      globals.mapleader = " ";
      keymaps = [
        {
          mode = "n";
          key = "<leader>ff";
          action = "<cmd>Telescope find_files<CR>";
        }
        {
          mode = "n";
          key = "<leader>fg";
          action = "<cmd>Telescope live_grep<CR>";
        }
        {
          mode = "n";
          key = "<leader>fb";
          action = "<cmd>Telescope buffers<CR>";
        }
        {
          mode = "n";
          key = "<leader>fh";
          action = "<cmd>Telescope help_tags<CR>";
        }
        {
          mode = ["n" "v"];
          key = "<leader>y";
          action = "\"+y";
        }
        {
          mode = ["n" "v"];
          key = "<leader>p";
          action = "\"+p";
        }
        {
          mode = "n";
          key = "<C-n>";
          action = ":NvimTreeToggle<CR>";
        }
      ];
      plugins = {
        telescope.enable = true;
        lualine.enable = true;
        # nvim-tree.enable = true;
        # treesitter.enable = true;
        web-devicons.enable = true;
      };
      # colorschemes.onedark.enable = true;
      extraConfigVim = ''
        set list
        set listchars=space:·,eol:↴,tab:»\ ,trail:·,extends:⟩,precedes:⟨
      '';
      };
   };
}
