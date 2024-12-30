{ ... }:
{
  programs.nixvim.autoCmd = [
    {
      event = [ "BufWritePre" ];
      pattern = [ "*.xml" ];
      callback = { __raw = '' function() vim.lsp.buf.format({ async = false }) end ''; };
    }

    {
      event = [ "BufWritePre" ];
      pattern = [ "*.go" ];
      callback.__raw = ''
        function()
          vim.lsp.buf.format()
          local params = vim.lsp.util.make_range_params()
          params.context = {only = {"source.organizeImports"}}
          local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
          for _, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
              if r.edit then
                local enc = vim.lsp.get_client_by_id(1).offset_encoding or "utf-16"
                vim.lsp.util.apply_workspace_edit(r.edit, enc)
              else
                vim.lsp.buf.execute_command(r.command)
              end
            end
          end
        end
      '';
    }

    {
      event = [ "BufWritePre" ];
      pattern = [ "*.c" "*.h" ];
      callback = { __raw = '' function() vim.lsp.buf.format() end ''; };
    }

    {
      event = [ "BufWritePre" ];
      pattern = [ "*.nix" ];
      callback = { __raw = '' function() vim.lsp.buf.format() end ''; };
    }

    {
      event = [ "BufWritePre" ];
      pattern = [ "*.ts" "*.js" "*.svelte" "*.json" "*.css" "*.html" ];
      callback = { __raw = '' function() vim.lsp.buf.format({ async = false }) end ''; };
    }

    {
      event = [ "ColorScheme" "VimEnter" ];
      pattern = [ "*" ];
      callback = {
        __raw = ''
          function()
            vim.api.nvim_set_hl(0, 'Whitespace', { fg = '#606060', nocombine = true })
            vim.api.nvim_set_hl(0, 'NonText',    { fg = '#606060', nocombine = true })
            vim.api.nvim_set_hl(0, 'SpecialKey', { fg = '#606060', nocombine = true })
            vim.api.nvim_set_hl(0, 'Comment', { fg = '#aaaaaa', nocombine = true })
            vim.api.nvim_set_hl(0, 'Normal', { fg = '#ffffff', nocombine = true })
          end
        '';
      };
    }
  ];
}

