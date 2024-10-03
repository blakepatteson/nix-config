{ config, pkgs, ... }:
{
  environment.etc."xdg/kitty/kitty.conf".text = ''
    font_family Victor Mono
    font_size 20.0
    scrollback_pager ${pkgs.neovim}/bin/nvim -c "set nonumber nolist showtabline=0 foldcolumn=0" -c "autocmd TermOpen * normal G" -c "silent write! /tmp/kitty_scrollback_buffer | te cat /tmp/kitty_scrollback_buffer - " -c "set clipboard=unnamedplus" -c "vmap y ygv<Esc>" -c "nnoremap y yy" -c "nnoremap Y y$" -c "let @+=@\"" -c "set clipboard=unnamedplus"
    scrollback_lines 10000
    allow_remote_control yes
    map ctrl+shift+m show_scrollback
    map ctrl+v paste_from_clipboard
    map ctrl+n new_os_window
    map ctrl+w close_window
    map ctrl+t new_tab
    map ctrl+q close_tab
    
    map ctrl+l clear_terminal scroll active
    map ctrl+equal change_font_size all +2.0
    map ctrl+minus change_font_size all -2.0
    map ctrl+backspace change_font_size all 0

    # New scrolling mappings
    map ctrl+u scroll_page_up
    map ctrl+d scroll_page_down

    # Vi mode specific mappings
    map ctrl+shift+j scroll_line_down
    map ctrl+shift+k scroll_line_up
    map ctrl+shift+h scroll_to_prompt -1
    map ctrl+shift+l scroll_to_prompt 1
    map ctrl+shift+g scroll_to_prompt 0
    map ctrl+shift+G scroll_to_prompt -1
  '';

   environment.etc.bashrc = {
    text = ''
      # ~/.bashrc: executed by bash(1) for non-login shells.

      # If not running interactively, don't do anything
      [ -z "$PS1" ] && return

      # don't put duplicate lines in the history.
      HISTCONTROL=ignoredups:ignorespace

      # append to the history file, don't overwrite it
      shopt -s histappend

      # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
      HISTSIZE=1000
      HISTFILESIZE=2000

      # check the window size after each command and, if necessary,
      # update the values of LINES and COLUMNS.
      shopt -s checkwinsize

      # make less more friendly for non-text input files, see lesspipe(1)
      [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

      # set a fancy prompt with date and time
      PS1='\[\033[01;31m\][\D{%Y-%m-%d}]\[\033[00m\] \[\033[01;32m\][\t]\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

      # enable color support of ls and also add handy aliases
      if [ -x /usr/bin/dircolors ]; then
          test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
          alias ls='ls --color=auto'
          alias grep='grep --color=auto'
          alias fgrep='fgrep --color=auto'
          alias egrep='egrep --color=auto'
      fi

      # some more ls aliases
      alias ll='ls -alF'
      alias la='ls -A'
      alias l='ls -CF'
      alias cls='clear && printf "\033[3J"'

      # Add any additional custom configurations below this line
      # For example:
      # export PATH=$PATH:/path/to/custom/scripts
      # alias myalias='custom command'
    '';
    mode = "0644";
  };

  # This ensures that the /etc/bashrc file is sourced for interactive non-login shells
  environment.interactiveShellInit = ''
    if [ -f /etc/bashrc ]; then
      . /etc/bashrc
    fi
  '';

    environment.etc."neovim/init.vim" = {
    text = ''
      " Enable relative line numbers
      set number relativenumber

      " Enable syntax highlighting
      syntax enable

      " Set tab width to 4 spaces
      set tabstop=4
      set shiftwidth=4
      set expandtab

      " Enable mouse support
      set mouse=a

      " Enable clipboard support
      set clipboard+=unnamedplus

      " Enable auto-indentation
      set autoindent
      set smartindent

      " Enable incremental search
      set incsearch

      " Highlight search results
      set hlsearch

      " Enable case-insensitive search
      set ignorecase
      set smartcase

      " Enable undo persistence
      set undofile
      set undodir=/tmp/.vim-undo-dir

      " Enable LSP
      lua << EOF
      local nvim_lsp = require('lspconfig')

      -- Use an on_attach function to only map the following keys
      -- after the language server attaches to the current buffer
      local on_attach = function(client, bufnr)
        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

        -- Enable completion triggered by <c-x><c-o>
        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        local opts = { noremap=true, silent=true }

        -- See `:help vim.lsp.*` for documentation on any of the below functions
        buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
        buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
        buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
        buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
      end

      -- Use a loop to conveniently call 'setup' on multiple servers and
      -- map buffer local keybindings when the language server attaches
      local servers = { 'pyright', 'rust_analyzer', 'tsserver' }
      for _, lsp in ipairs(servers) do
        nvim_lsp[lsp].setup {
          on_attach = on_attach,
          flags = {
            debounce_text_changes = 150,
          }
        }
      end
      EOF

      " Plugin configurations (if you decide to add plugins later)
      " ...

    '';
    mode = "0644";
  };
  
}