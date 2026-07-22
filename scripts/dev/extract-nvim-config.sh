set -euo pipefail

WRAPPER="$(readlink -f "$(command -v nvim)")"
if [ -z "$WRAPPER" ]; then
    echo "Error: nvim not found on PATH" >&2
    exit 1
fi

INIT_LUA_PATH=$(grep -oE "dofile\(\\\\'[^']*init\.lua" "$WRAPPER" \
                  | sed "s/dofile(\\\\'//" | head -1)

if [ -z "$INIT_LUA_PATH" ] || [ ! -f "$INIT_LUA_PATH" ]; then
    echo "Error: could not locate nixvim init.lua from wrapper: $WRAPPER" >&2
    exit 1
fi

echo "Found init.lua at: $INIT_LUA_PATH"

LAZY_SETUP='local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  "L3MON4D3/LuaSnip",
  "RRethy/nvim-base16",
  "akinsho/bufferline.nvim",
  "echasnovski/mini.nvim",
  "folke/which-key.nvim",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/nvim-cmp",
  "lewis6991/gitsigns.nvim",
  "lukas-reineke/indent-blankline.nvim",
  "neovim/nvim-lspconfig",
  "nvim-lua/lsp-status.nvim",
  "norcalli/nvim-colorizer.lua",
  "numToStr/Comment.nvim",
  "nvim-lua/plenary.nvim",
  "nvim-lualine/lualine.nvim",
  "nvim-telescope/telescope.nvim",
  "nvim-tree/nvim-web-devicons",
  "nvim-treesitter/nvim-treesitter",
  "nvimtools/none-ls.nvim",
  "rcarriga/nvim-notify",
  "stevearc/conform.nvim",
  "stevearc/oil.nvim",
})
'

OUTPUT_DIR="$HOME/dev"
OUTPUT_FILE="$OUTPUT_DIR/init.lua"
mkdir -p "$OUTPUT_DIR"

echo "Writing $OUTPUT_FILE"
{
    printf '%s\n' "$LAZY_SETUP"

    # Strip lines that hard-code /nix/store host_prog paths (Ruby/Python
    # providers). Rewrite absolute /nix/store/<hash>-<name>/bin/<cmd> paths
    # to bare <cmd> so LSP servers resolve via PATH on the target machine.
    sed -e '/host_prog *=.*"\/nix\/store/d' \
        -e 's|"/nix/store/[^"]*/bin/\([^"/]*\)"|"\1"|g' \
        -e 's|"/nix/store/[^"]*/lib/zig"|"zig-lib-placeholder"|g' \
        "$INIT_LUA_PATH"
} > "$OUTPUT_FILE"

REMAINING=$(grep -c '/nix/store' "$OUTPUT_FILE" || true)
echo "Done: $(wc -l < "$OUTPUT_FILE") lines, $REMAINING remaining /nix/store references"
if [ "$REMAINING" -gt 0 ]; then
    echo "  (review these manually before using on non-NixOS):"
    grep -n '/nix/store' "$OUTPUT_FILE" | head -10
fi
