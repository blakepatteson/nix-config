{ pkgs, ... }:
{
  programs.nixvim.plugins = {
    telescope.enable = true;
    lualine.enable = true;
    web-devicons.enable = true;
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
      userDefaultOptions = {
        css = true;
        tailwind = true;
      };
    };
    oil = {
      enable = true;
      settings = {
        view_options = { show_hidden = true; };
        float = { padding = 2; max_width = 100; max_height = 20; };
      };
    };

    # Add LuaSnip
    luasnip = {
      enable = true;
    };

    # Update cmp configuration
    cmp = {
      enable = true;
      settings = {
        snippet = {
          expand = "function(args) require('luasnip').lsp_expand(args.body) end";
        };
        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-n>" = "cmp.mapping.select_next_item()";
          "<C-p>" = "cmp.mapping.select_prev_item()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_next_item() elseif require('luasnip').expand_or_jumpable() then require('luasnip').expand_or_jump() else fallback() end end, {'i', 's'})";
          "<S-Tab>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_prev_item() elseif require('luasnip').jumpable(-1) then require('luasnip').jump(-1) else fallback() end end, {'i', 's'})";
        };
        sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; } # Add luasnip as a source
          { name = "path"; }
          { name = "buffer"; }
        ];
      };
    };
  };
}
