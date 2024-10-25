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
      opts = {
        number = true;
        relativenumber = true;
        clipboard = "unnamedplus";
      };
      globals.mapleader = " ";
      keymaps = [
        {
          mode = "n";
          key = "<C-p>";
          action = "<cmd>Telescope find_files<CR>";
        }
	{
	  mode = "n";
	  key = "<C-h>";
	  action = ":%s//g<Left><Left>";  # This opens find/replace command with cursor ready
	}
        {
          mode = "n";
          key = "<C-f>";
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
          key = "-";
          action = "<CMD>Oil<CR>";
        }
      ];
      plugins = {
        telescope.enable = true;
        lualine.enable = true;
        web-devicons.enable = true;
        oil = {
          enable = true;
          settings = {
            view_options = {
              show_hidden = true;
            };
            float = {
              padding = 2;
              max_width = 100;
              max_height = 20;
            };
          };
        };
      };
      extraConfigVim = ''
        set list
        set listchars=space:·,eol:↴,tab:»\ ,trail:·,extends:⟩,precedes:⟨
      '';
    };
  };
}
