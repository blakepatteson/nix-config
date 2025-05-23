# Script to extract nixvim init.lua and prepend lazy.nvim setup
set -e  # Exit on any error

# Step 1 & 2: Get the init.lua path from running nvim
echo "Getting init.lua path from nvim..."

# Create a temporary file to capture the scriptnames output
TEMP_FILE=$(mktemp)
nvim --headless -c 'redir! > '"$TEMP_FILE"'' -c 'scriptnames' -c 'redir END' -c 'qall' 2>/dev/null

# Extract the init.lua path
INIT_LUA_PATH=$(grep -E '/nix/store/.*init\.lua$' "$TEMP_FILE" | head -1 | sed 's/^[[:space:]]*[0-9]*:[[:space:]]*//')

# Clean up temp file
rm -f "$TEMP_FILE"

if [ -z "$INIT_LUA_PATH" ]; then
    echo "Error: Could not find nixvim init.lua path"
    echo "Let's try a manual approach..."
    
    # Fallback: use the most recent init.lua we can find
    INIT_LUA_PATH=$(fd "init.lua" /nix/store | awk 'length($0) == 52' | xargs ls -lt 2>/dev/null | head -1 | awk '{print $NF}')
    
    if [ -z "$INIT_LUA_PATH" ]; then
        echo "Error: Could not find any suitable init.lua file"
        exit 1
    fi
    
    echo "Using fallback method, found: $INIT_LUA_PATH"
fi

echo "Found init.lua at: $INIT_LUA_PATH"

# Step 3: Read the contents of the file
if [ ! -f "$INIT_LUA_PATH" ]; then
    echo "Error: File $INIT_LUA_PATH does not exist"
    exit 1
fi

# Step 4: Create the lazy.nvim setup code
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
  "RRethy/nvim-base16",  
  "nvim-tree/nvim-web-devicons",  
  "hrsh7th/nvim-cmp",
  "folke/which-key.nvim",
  "nvim-treesitter/nvim-treesitter",  
  "nvim-lua/plenary.nvim",  
  "nvim-telescope/telescope.nvim",
  "stevearc/oil.nvim",
  "nvimtools/none-ls.nvim",
  "L3MON4D3/LuaSnip",
  "nvim-lualine/lualine.nvim",
  "lukas-reineke/indent-blankline.nvim",
  "lewis6991/gitsigns.nvim",
  "stevearc/conform.nvim",
  "numToStr/Comment.nvim",
  "norcalli/nvim-colorizer.lua",
  "akinsho/bufferline.nvim",
  "hrsh7th/cmp-nvim-lsp",
  "neovim/nvim-lspconfig",
  "rcarriga/nvim-notify",
})

'

# Step 5: Create output directory and write the file
OUTPUT_DIR="$HOME/dev"
OUTPUT_FILE="$OUTPUT_DIR/init.lua"

mkdir -p "$OUTPUT_DIR"

echo "Creating modified init.lua at: $OUTPUT_FILE"

# Write lazy setup first, then append original content
echo "$LAZY_SETUP" > "$OUTPUT_FILE"
cat "$INIT_LUA_PATH" >> "$OUTPUT_FILE"

echo "Successfully created $OUTPUT_FILE"
echo "File size: $(wc -l < "$OUTPUT_FILE") lines"
