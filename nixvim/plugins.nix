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
            analyses = { unusedparams = true; shadow = true; };
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
  };
}
