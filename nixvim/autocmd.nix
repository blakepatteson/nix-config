{ ... }:
{
  programs.nixvim.autoCmd = [
    {
      event = [ "BufWritePre" ];
      pattern = [ "*.xml" ];
      callback = {
        __raw = '' 
            function() 
              if vim.b.autoformat ~= false and not vim.b.skip_next_format then
                vim.lsp.buf.format({ async = false }) 
              end
            end 
          '';
      };
    }

    {
      event = [ "BufWritePre" ];
      pattern = [ "*.go" ];
      callback.__raw = ''
           function()
              if vim.b.autoformat ~= false and not vim.b.skip_next_format then
             -- Format the buffer
             vim.lsp.buf.format({ async = false })
             -- Organize imports
             local params = vim.lsp.util.make_range_params()
             params.context = {only = {"source.organizeImports"}}
             local result = vim.lsp.buf_request_sync(
                 0, "textDocument/codeAction", params, 3000)
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
        end
      '';
    }

    {
      event = [ "BufWritePre" ];
      pattern = [ "*.c" "*.h" ];
      callback = { __raw = '' function() if not vim.b.skip_next_format then vim.lsp.buf.format() end end ''; };
    }

    {
      event = [ "BufWritePre" ];
      pattern = [ "*.nix" ];
      callback = { __raw = '' function() if not vim.b.skip_next_format then vim.lsp.buf.format() end end ''; };
    }

    {
      event = [ "BufWritePre" ];
      pattern = [ "*.ts" "*.js" "*.svelte" "*.json" "*.css" "*.html" ];
      callback = { __raw = '' function() if not vim.b.skip_next_format then vim.lsp.buf.format({ async = false }) end end ''; };
    }

    {
      event = [ "ColorScheme" "VimEnter" ];
      pattern = [ "*" ];
      callback.__raw = /*lua*/ ''
        function()
          vim.api.nvim_set_hl(0, 'Whitespace', { fg = '#606060', nocombine = true })
          vim.api.nvim_set_hl(0, 'NonText',    { fg = '#606060', nocombine = true })
          vim.api.nvim_set_hl(0, 'Comment',    { fg = '#aaaaaa', nocombine = true })
          vim.api.nvim_set_hl(0, 'SpecialKey', { fg = '#ffffff', nocombine = true })
          vim.api.nvim_set_hl(0, 'Normal',     { fg = '#ffffff', nocombine = true })
        end
      '';
    }
  ];
}

