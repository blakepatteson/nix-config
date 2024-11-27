{ ... }:
{
  programs.nixvim.autoCmd = [
    {
      event = [ "BufWritePre" ];
      pattern = [ "*.go" ];
      callback = {
        __raw = ''
          function()
            vim.lsp.buf.format()
              
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
  ];
}

