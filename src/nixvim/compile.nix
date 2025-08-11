{ ... }:
{
  programs.nixvim = {
    extraConfigLua = ''
      dofile("${./compile-runner.lua}")
    '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>mc";
        action = ":CompileCommand<CR>";
        options = {
          silent = true;
          desc = "Set compile command";
        };
      }

      {
        mode = "n";
        key = "<leader>mr";
        action = ":CompileRun<CR>";
        options = {
          silent = true;
          desc = "Run compile command";
        };
      }

      {
        mode = "n";
        key = "<leader>md";
        action = ":CompileClear<CR>";
        options = {
          silent = true;
          desc = "Clear compile command";
        };
      }

      {
        mode = "n";
        key = "<leader>mp";
        action = ":lua _G.browse_compile_history('prev')<CR>";
        options = {
          silent = true;
          desc = "Previous compile command";
        };
      }

      {
        mode = "n";
        key = "<leader>mn";
        action = ":lua _G.browse_compile_history('next')<CR>";
        options = {
          silent = true;
          desc = "Next compile command";
        };
      }

      {
        mode = "n";
        key = "<leader>mk";
        action = ":CompileKill<CR>";
        options = {
          silent = true;
          desc = "Kill compile process";
        };
      }

      {
        mode = "n";
        key = "<leader>mh";
        action = ":lua _G.telescope_compile_history()<CR>";
        options = {
          silent = true;
          desc = "Search compile history";
        };
      }
    ];
  };
}