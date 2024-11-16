{ pkgs, ... }:
{
  programs.nixvim.plugins = {
    telescope.enable = true;
    lualine.enable = true;
    # treesitter.enable = true;
    luasnip.enable = true;
    web-devicons.enable = true;
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

    notify.enable = true;
    which-key.enable = true;
    gitsigns = {
      enable = true;
      settings = {
        signs = {
          add = { text = "+"; };
          change = { text = "*"; };
          changedelete = { text = "~"; };
          delete = { text = "_"; };
          topdelete = { text = "‾"; };
          untracked = { text = "┆"; };
        };
        watch_gitdir = { follow_files = true; };
        on_attach = ''
          function(bufnr)
            local gs = package.loaded.gitsigns
            -- Navigation
            vim.keymap.set('n', ']h', gs.next_hunk, {buffer = bufnr})
            vim.keymap.set('n', '[h', gs.prev_hunk, {buffer = bufnr})
          end
        '';
      };
    };
    lsp = {
      enable = true;
      servers = {
        nil_ls = {
          enable = true;
          settings = {
            formatting = { command = [ "nixpkgs-fmt" ]; };
            nix = {
              flake = { autoEvalInputs = true; };
              maxMemoryMB = 2048;
              diagnostics = { ignored = [ ]; excludedFiles = [ ]; };
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
            # Add these for refactoring support
            codelenses = {
              gc_details = true;
              generate = true;
              regenerate_cgo = true;
              tidy = true;
              upgrade_dependency = true;
              vendor = true;
              test = true; # Add this
              extract = true; # Add this
            };

            # Add experimental features
            experimentalWorkspaceModule = true;

            # Add refactoring settings
            semanticTokens = true;

            # Enable all analyses
            analyses = {
              unusedparams = true;
              shadow = true;
              fieldalignment = true;
              nilness = true;
              unusedwrite = true;
              useany = true;
              refactor = true;
              extractmethod = true; # Add this specifically for extract method/function
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
        svelte = {
          enable = true;
          package = pkgs.nodePackages.svelte-language-server;
          settings = {
            svelte = {
              plugin = {
                typescript = {
                  enable = true;
                };
              };
            };
          };
        };
        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
          settings = {
            assist = {
              importGranularity = "module";
              importPrefix = "by_self";
            };
            cargo = {
              loadOutDirsFromCheck = true;
              allFeatures = true;
            };
            checkOnSave = true;
            check = {
              command = "clippy";
              extraArgs = [ "--no-deps" ];
            };
            completion = {
              autoimport = {
                enable = true;
              };
            };
            diagnostics = {
              enable = true;
              experimental = {
                enable = true;
              };
            };
            procMacro = {
              enable = true;
            };
          };
        };
      };

      onAttach = ''
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
    nvim-colorizer = {
      enable = true;
      userDefaultOptions = { css = true; tailwind = true; };
    };
    oil = {
      enable = true;
      settings = {
        view_options = { show_hidden = true; };
        float = { padding = 2; max_width = 100; max_height = 20; };
      };
    };
    # Update cmp configuration
    cmp = {
      enable = true;
      settings = {
        snippet = {
          expand = ''
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
          "<Tab>" = ''
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
          "<S-Tab>" = ''
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
