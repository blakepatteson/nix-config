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
        swapfile = false;    
        backup = false;      
        writebackup = false; 
      };

      globals = {
        mapleader = " ";
        VM_mouse_mappings = 1;  
        VM_maps = {
          "Find Under" = "<C-m>";
          "Find Subword Under" = "<C-m>";
        };
      };

      keymaps = [
        {
          mode = "n";
          key = "]d";
          action = "vim.diagnostic.goto_next";
        }
        {
          mode = "n";
          key = "[d";
          action = "vim.diagnostic.goto_prev";
        }
        {
          mode = "n";
          key = "gd";
          action = "vim.lsp.buf.definition";
        }
        {
          mode = "n";
          key = "K";
          action = "vim.lsp.buf.hover";
        }
        {
          mode = "n";
          key = "<leader>rn";
          action = "vim.lsp.buf.rename";
        }
        {
          mode = "n";
          key = "<leader>ca";
          action = "vim.lsp.buf.code_action";
        }
        {
          mode = "n";
          key = "gr";
          action = "vim.lsp.buf.references";
        }
        {
          mode = "n";
          key = "<C-p>";
          action = "<cmd>Telescope find_files<CR>";
        }
        {
          mode = "n";
          key = "<C-h>";
          action = ":%s//g<Left><Left>";  
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
          action = "$";  
        }
        {
          mode = "n";
          key = "<leader>j";
          action = "}"; 
        }
        {
          mode = "n";
          key = "<leader>k";
          action = "{";
        }
        {
          mode = "n";
          key = "<leader>n";
          action = "]m";
        }
      ];

      autoCmd = [
        {
          event = ["BufWritePre"];
          pattern = ["*.go"];
          callback = {
            __raw = ''
              function()
                -- Format the buffer
                vim.lsp.buf.format()
                
                -- Organize imports
                local params = vim.lsp.util.make_range_params()
                params.context = {only = {"source.organizeImports"}}
                local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
                for _, res in pairs(result or {}) do
                  for _, r in pairs(res.result or {}) do
                    if r.edit then
                      vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
                    else
                      vim.lsp.buf.execute_command(r.command)
                    end
                  end
                end
              end
            '';
          };
        }
      ];

      plugins = {
        telescope.enable = true;
        lualine.enable = true;
        web-devicons.enable = true;
        
        lsp = {
          enable = true;
          servers = {
            gopls = {
              enable = true;
              settings = {
                analyses = {
                  unusedparams = true;
                  shadow = true;
                };
                staticcheck = true;
                gofumpt = true;
                hints = {
                  assignVariableTypes = true;
                  compositeLiteralFields = true;
                  compositeLiteralTypes = true;
                  constantValues = true;
                  functionTypeParameters = true;
                  parameterNames = true;
                  rangeVariableTypes = true;
                };
                importShortcut = "Both";
                analyses.unusedwrite = true;
                codelenses = {
                  gc_details = true;
                  generate = true;
                  regenerate_cgo = true;
                  tidy = true;
                  upgrade_dependency = true;
                  vendor = true;
                };
              };
            };
          };
        };

        # Uncomment if you want to use treesitter
        # treesitter = {
        #   enable = true;
        #   settings = {
        #     ensure_installed = ["go" "nix"];
        #   };
        # };

        # Uncomment if you want to use cmp
        # cmp = {
        #   enable = true;
        #   settings = {
        #     sources = [
        #       {name = "nvim_lsp";}
        #       {name = "path";}
        #       {name = "buffer";}
        #     ];
        #     # mapping = {
        #     #   "<CR>" = "cmp.mapping.confirm()";
        #     #   "<Tab>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_next_item() else fallback() end end)";
        #     #   "<S-Tab>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_prev_item() else fallback() end end)";
        #     # };
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
