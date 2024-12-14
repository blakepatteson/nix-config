{ pkgs, ... }:
{
  programs.nixvim.plugins = {
    lualine.enable = true;
    luasnip.enable = true;
    notify.enable = true;
    which-key.enable = true;
    web-devicons.enable = true;

    telescope = {
      enable = true;
      settings = {
        defaults = {
          vimgrep_arguments = [
            "rg"
            "--color=never"
            "--no-heading"
            "--with-filename"
            "--line-number"
            "--column"
            "--smart-case"
            "--multiline" # Enable multiline matching
            "--pcre2" # Use PCRE2 regex engine for better pattern matching
          ];
          mappings.i = {
            "<F4>" = "move_selection_next";
            "<F16>" = "move_selection_previous";
            "<Tab>" = "move_selection_next";
            "<S-Tab>" = "move_selection_previous";
          };
        };
      };
    };
    none-ls = {
      enable = true;
      sources = { formatting = { prettier = { enable = true; }; }; };
    };

    comment = {
      enable = true;
      settings = { mappings = { basic = true; extra = true; }; };
    };

    treesitter = {
      enable = true;
      nixvimInjections = true;

      settings = {
        ensure_installed = [
          "html"
          "svelte"
          "css"
          "javascript"
          "typescript"
          "nix"
          "lua"
          "vim"
          "go"
          "python"
          "javascript"
          "typescript"
          "c"
        ];

        highlight = {
          enable = true;
          additional_vim_regex_highlighting = false;
          use_languagetree = true;
        };

        # Incremental selection based on syntax tree
        incremental_selection = {
          enable = true;
          keymaps = {
            init_selection = "<C-space>";
            node_incremental = "<C-space>";
            node_decremental = "<C-backspace>";
            scope_incremental = "<C-s>";
          };
        };

        # Auto-pairs and rainbow parentheses
        rainbow = { enable = true; extended_mode = true; max_file_lines = 1000; };

        indent = { enable = true; };
        fold = { enable = true; };
        matchup = { enable = true; };

        textobjects = {
          move = {
            enable = true;
            goto_next_start = { "]f" = "@function.outer"; "]c" = "@class.outer"; };
            goto_previous_start = { "[f" = "@function.outer"; "[c" = "@class.outer"; };
          };
        };
      };

      grammarPackages = with pkgs.vimPlugins.nvim-treesitter-parsers; [
        nix
        lua
        vim
        go
        python
        javascript
        typescript
        json
        yaml
        toml
        xml
        markdown
        bash
        c
        html
        svelte
        css
        javascript
        typescript
      ];
    };

    bufferline = {
      enable = true;
      settings = {
        options = {
          mode = "buffers";
          numbers = "none";
          close_command = "bdelete! %d";
          right_mouse_command = "bdelete! %d";
          left_mouse_command = "buffer %d";
          middle_mouse_command = null;
          indicator = { icon = "▎"; style = "icon"; };
          buffer_close_icon = "󰅖";
          modified_icon = "●";
          close_icon = "";
          left_trunc_marker = "";
          right_trunc_marker = "";
          show_buffer_icons = true;
          show_buffer_close_icons = true;
          show_close_icon = true;
          show_tab_indicators = true;
          separator_style = "thin";
          enforce_regular_tabs = false;
          always_show_bufferline = true;
        };
      };
    };

    gitsigns = {
      enable = true;
      settings = {
        watch_gitdir = { follow_files = true; };
        signs = {
          add = { text = "+"; };
          change = { text = "*"; };
          changedelete = { text = "~"; };
          delete = { text = "_"; };
          topdelete = { text = "‾"; };
          untracked = { text = "┆"; };
        };
      };
    };

    lsp = {
      enable = true;
      servers = {
        nixd.enable = true;
        nil_ls = {
          enable = true;
          settings = {
            formatting = { command = [ "nixpkgs-fmt" ]; };
            nix = {
              flake = { autoEvalInputs = false; }; # Set to false to avoid crashes
              maxMemoryMB = 2048;
            };
          };
        };

        gopls = {
          enable = true;
          settings = {
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

            codelenses = {
              gc_details = true;
              generate = true;
              regenerate_cgo = true;
              tidy = true;
              upgrade_dependency = true;
              vendor = true;
              test = true;
              extract = true;
            };

            experimentalWorkspaceModule = true;
            semanticTokens = true;

            analyses = {
              unusedparams = true;
              shadow = true;
              fieldalignment = true;
              nilness = true;
              unusedwrite = true;
              useany = true;
              refactor = true;
              extractmethod = true;
            };
          };
        };

        clangd = {
          enable = true;
          settings = {
            fallbackFlags = [ "-std=c11" ];
            style = {
              BasedOnStyle = "LLVM";
              IndentWidth = 2;
              TabWidth = 2;
              UseTab = false;
              ColumnLimit = 80;
            };
          };
        };

        lemminx = { enable = true; package = pkgs.lemminx; };

        svelte = {
          enable = true;
          package = pkgs.nodePackages.svelte-language-server;
          settings = { svelte = { plugin = { typescript = { enable = true; }; }; }; };
        };
      };

      onAttach = /* lua */''
        vim.diagnostic.config({
          virtual_text = true,
          signs = true,
          underline = true,
          update_in_insert = false,
          severity_sort = true,
        })
        -- Enable workspace diagnostics
        vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
          vim.lsp.diagnostic.on_publish_diagnostics, {
            virtual_text = true,
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            workspace = true,
          }
        )
      '';
    };

    indent-blankline.enable = true;
    colorizer = {
      enable = true;
      settings = {
        user_default_options = { css = true; tailwind = true; };
        filetypes = [ "*" ]; # Enable for all filetypes
      };
    };

    oil = {
      enable = true;
      settings = {
        view_options = { show_hidden = true; };
        float = { padding = 2; max_width = 100; max_height = 20; };
        keymaps = {
          "<C-p>" = false; # Disable the default Ctrl+p binding
          "<C-S-p>" = "actions.preview"; # Add new Ctrl+Shift+p binding
        };
      };
    };

    cmp = {
      enable = true;
      settings = {
        snippet = {
          expand = /* lua */ ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';
        };
        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-n>" = "cmp.mapping.select_next_item()";
          "<C-p>" = "cmp.mapping.select_prev_item()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = /* lua */ ''
            cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif require('luasnip').expand_or_jumpable() then
                require('luasnip').expand_or_jump()
              else
                fallback()
              end
            end, {'i', 's'})
          '';
          "<S-Tab>" = /* lua */ ''
            cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif require('luasnip').jumpable(-1) then
                require('luasnip').jump(-1)
              else
                fallback()
              end
            end, {'i', 's'})
          '';
        };
        sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
      };
    };
  };
}
