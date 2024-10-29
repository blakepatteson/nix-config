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
        swapfile = false;    # No more swap files
        backup = false;      # No backup files
        writebackup = false; # No backup files during write
      };
      globals = {
        mapleader = " ";
        VM_mouse_mappings = 1;  # Enable mouse support for vim-visual-multi
        VM_maps = {
          "Find Under" = "<C-m>";
          "Find Subword Under" = "<C-m>";
        };
      };
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
         {
          mode = ["n" "v"];
          key = "H";
          action = "^";
        }
        {
          mode = ["n" "v"];
          key = "L";
          action = "$";  # Map L to end of line (easier than $)
        }
        # Brace navigation
        {
          mode = "n";
          key = "<leader>j";
          action = "}";  # Jump to next paragraph/block
        }
        {
          mode = "n";
          key = "<leader>k";
          action = "{";  # Jump to previous paragraph/block
        }
        # Add bracket navigation
        {
          mode = "n";
          key = "<leader>n";
          action = "]m";  # Next method/function
        }
        {
          mode = "n";
          key = "<leader>p";
          action = "[m";  # Previous method/function
        }
        # {
        #   mode = "n";
        #   key = "gd";
        #   action = "<cmd>lua vim.lsp.buf.definition()<CR>";
        # }
        # {
        #   mode = "n";
        #   key = "K";
        #   action = "<cmd>lua vim.lsp.buf.hover()<CR>";
        # }
        # {
        #   mode = "n";
        #   key = "<leader>rn";
        #   action = "<cmd>lua vim.lsp.buf.rename()<CR>";
        # }
        # {
        #   mode = "n";
        #   key = "<leader>ca";
        #   action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
        # }
      ];
      plugins = {
        telescope.enable = true;
        lualine.enable = true;
        web-devicons.enable = true;
        
        # lsp = {
        #   enable = true;
        #   servers = {
        #     nil_ls = {
        #       enable = true;
        #       settings.formatting.command = ["alejandra"];
        #     };
        #     gopls = {
        #       enable = true;
        #       settings = {
        #         analyses = {
        #           unusedparams = true;
        #           shadow = true;
        #         };
        #         staticcheck = true;
        #         gofumpt = true;
        #       };
        #     };
        #   };
        #   onAttach = ''
        #     function(client, bufnr)
        #       vim.api.nvim_create_autocmd('BufWritePre', {
        #         buffer = bufnr,  -- Changed from buffer to bufnr
        #         callback = function()
        #           vim.lsp.buf.format({ async = false })
        #         end
        #       })
        #     end
        #   '';
        #   keymaps = {
        #     diagnostic = {
        #       enable = true;  # Enable with just basic settings
        #       prev = "[[";
        #       next = "]]";
        #     };
        #     lspBuf = {
        #       enable = true;  # Enable with just basic settings
        #       format = "<leader>f";
        #       hover = "K";
        #       rename = "<leader>rn";
        #       codeAction = "<leader>ca";
        #       definition = "gd";
        #       references = "gr";
        #     };
        #   };
        # };

        # treesitter = {
        #   enable = true;
        #   settings = {
        #     ensure_installed = ["go" "nix"];
        #   };
        # };

        # cmp = {
        #   enable = true;
        #   settings = {
        #     sources = [
        #       {name = "nvim_lsp";}
        #       {name = "path";}
        #       {name = "buffer";}
        #     ];
        #     mapping = {
        #       "<CR>" = "cmp.mapping.confirm({ select = true })";
        #       "<Tab>" = "cmp.mapping.select_next_item()";
        #       "<S-Tab>" = "cmp.mapping.select_prev_item()";
        #     };
        #   };
        # };

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
      extraPlugins = with pkgs.vimPlugins; [
        vim-visual-multi
      ];
      extraConfigVim = ''
        set list
        set listchars=space:·,eol:↴,tab:»\ ,trail:·,extends:⟩,precedes:⟨
      '';
    };
  };
}
