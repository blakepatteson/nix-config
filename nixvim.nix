# nixvim.nix
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
      VM_maps = {
        "Find Under" = "<C-m>";
        "Find Subword Under" = "<C-m>";
      };
    };
  };
}

