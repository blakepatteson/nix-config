{ pkgs, ... }:
{
  programs.nixvim.plugins = {
    lualine.enable = true;
    luasnip.enable = true;
    which-key.enable = true;
    web-devicons.enable = true;

    notify = { enable = true; settings = { background_colour = "#000000"; }; };

    telescope = {
      enable = true;
      settings = {
        defaults = {
          file_ignore_patterns = [
            "^node_modules/"
            "^.git/"
            "%.obj$"
            "%.o$"
            "%.a$"
            "%.bin$"
            "%.dll$"
            "%.so$"
            "%.tar.gz$"
            "%.zip$"
            "%.iso$"
          ];
          layout_strategy = "horizontal";
          layout_config = {
            horizontal = {
              preview_width = 0.55;
              results_width = 0.45;
            };
            width = 0.95;
            height = 0.85;
            preview_cutoff = 120;
          };
          prompt_prefix = "🔍 ";
          prompt_title = false;
          results_title = false;
          dynamic_preview_title = true;
          path_display = [ "truncate" ];

          selection_strategy = "reset";
          sorting_strategy = "ascending";
          scroll_strategy = "cycle";
          selection_caret = "> ";
          entry_prefix = "  ";

          cache_picker = { num_pickers = 10; limit_entries = 100000; };

          file_browser = {
            depth = 1;
            group_empty = true;
            hidden = true;
            respect_gitignore = false;
          };

          vimgrep_arguments = [
            "rg"
            "--color=never"
            "--no-heading"
            "--with-filename"
            "--line-number"
            "--column"
            "--smart-case"
            "--multiline"
            "--pcre2"
            "--fixed-strings"
          ];
          mappings.i = {
            "<F4>" = "move_selection_next";
            "<F16>" = "move_selection_previous";
            "<Tab>" = "move_selection_next";
            "<S-Tab>" = "move_selection_previous";
            "<C-r>" = {
              __raw = ''require("telescope.actions").send_selected_to_qflist'';
            };
          };
        };

        find_files = {
          find_command = [
            "fd"
            "--type"
            "f"
            "--strip-cwd-prefix"
            "--hidden"
            "--follow"
          ];
          previewer = false;
          sort_lastused = true;
        };

        live_grep = {
          preview_cutoff = 1;
          results_title = false;
          dynamic_preview_title = true;
          path_display = [ "truncate" ];
        };
      };
    };

    none-ls = {
      enable = true;
      sources = {
        formatting = {
          prettier = { enable = true; disableTsServerFormatter = true; };
          gofmt = { enable = true; };
        };
        diagnostics = {
          golangci_lint = { enable = true; };
        };
      };
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
          "python"
          "c"
          "zig"
          "go"
          "json"
          "yaml"
          "toml"
          "xml"
          "markdown"
          "bash"
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
        zig
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
        current_line_blame = true;
        current_line_blame_opts = {
          virt_text = true;
          virt_text_pos = "eol";
          delay = 0;
          ignore_whitespace = false;
        };
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> • <summary>";
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
            nix = { maxMemoryMB = 4096; };
          };
        };

        gopls = {
          enable = true;
          filetypes = [ "go" "gomod" "gowork" "gotmpl" ];
          settings = {
            staticcheck = true;
            gofumpt = true;
            usePlaceholders = true;
            completeUnimported = true;

            hints = {
              assignVariableTypes = true;
              compositeLiteralFields = true;
              compositeLiteralTypes = true;
              constantValues = true;
              functionTypeParameters = true;
              parameterNames = true;
              rangeVariableTypes = true;
            };

            directoryFilters = [ "-.git" "-.vscode" "-.idea" "-node_modules" ];

            diagnostics = {
              enable = true;
              annotations = {
                bounds = true;
                escape = true;
                inline = true;
              };
            };

            analyses = {
              unusedparams = true;
              unusedwrite = true;
              useany = true;
              nilness = true;
              shadow = true;
              fieldalignment = true;
              refactor = true;
              extractmethod = true;
            };

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

            semanticTokens = true;
            templateExtensions = [ ];
            vulncheck = "Imports";

            diagnosticsDelay = "300ms";
            matcher = "Fuzzy";
            hoverKind = "FullDocumentation";
            importShortcut = "Both";
            experimentalWorkspaceModule = true;
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

        pyright = {
          enable = true;
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic";
                autoSearchPaths = true;
                useLibraryCodeForTypes = true;
                autoImportCompletions = true;
                diagnosticMode = "workspace";
              };
            };
          };
        };

        zls = {
          enable = true;
          package = pkgs.zls;
          cmd = [ "${pkgs.zls}/bin/zls" ];
          settings = {
            zig_exe_path = "${pkgs.zig}/bin/zig";
            zig_lib_path = "${pkgs.zig}/lib/zig";
            enable_snippets = true;
            enable_ast_check_diagnostics = false;
            enable_build_on_save = true;
            build_on_save_step = "check";
            prefer_ast_check_as_child_process = true;
            enable_autofix = false;
            enable_import_embedfile_argument_completions = true;
            warn_style = true;
            enable_semantic_tokens = true;
            enable_inlay_hints = true;
            inlay_hints_show_builtin = true;
            inlay_hints_exclude_single_argument = true;
            inlay_hints_hide_redundant_param_names = true;
            inlay_hints_hide_redundant_param_names_last_token = true;
            operator_completions = true;
            include_at_in_builtins = true;
            max_detail_length = 1048576;
          };
        };

        eslint = {
          enable = true;
          package = pkgs.nodePackages.vscode-langservers-extracted;
          settings = {
            format = { enable = true; };
            packageManager = "npm";
          };
        };

      };

      onAttach = /* lua */'' vim.diagnostic.config(
         {
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
            })

          -- Configure diagnostic display
          vim.diagnostic.config({
            virtual_text = true,
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = {
            source = "always",  -- Show source in diagnostic popup window
            border = "rounded"
            }
          })

          -- command to disable formatting 
          vim.api.nvim_create_user_command('SaveWithoutFormat', function()
            vim.b.skip_next_format = true
            vim.cmd('write')
            vim.b.skip_next_format = nil
            vim.notify('Saved without formatting')
          end, {})
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


    markdown-preview = {
      enable = true;
      settings = {
        auto_start = 0;
        browser = "";

        disable_sync_scroll = 0;
        hide_yaml_meta = 1;
        disable_filename = 0;
      };
    };

  };
}

