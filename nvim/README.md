# Neovim Configuration

This repository contains my personal configuration for the Neovim text editor. Neovim (or simply "nvim") is a modern, highly extensible text editor that is designed to be a drop-in replacement for the popular Vim editor. It provides a powerful and efficient editing experience for a wide range of programming languages and text files.

## Credits

I started going down this rabbit hole by following the excellent guide by [typecraft](https://www.youtube.com/@typecraft_dev) on YouTube. Checkout his playlists [Neovim for Newbs. FREE NEOVIM COURSE](https://www.youtube.com/playlist?list=PLsz00TDipIffreIaUNk64KxTIkQaGguqn) and [Neovim Configuration](https://www.youtube.com/playlist?list=PLsz00TDipIffxsNXSkskknolKShdbcALR). 

## Overview of Neovim

Neovim is a modal text editor, meaning it operates in different modes for different types of text manipulation tasks. The main modes are:

- **Normal mode**: This is the default mode where you can navigate and perform various editing commands.
- **Insert mode**: In this mode, you can enter text.
- **Visual mode**: This mode allows you to select and manipulate text.
- **Command mode**: This mode is used to execute commands and run ex commands.

Some of the most prominent key mappings in Neovim are:

- `?` - Show help
- `Ctrl Ww` - Switch between windows
- `i` - Enter Insert mode
- `v` - Enter Visual mode
- `:` - Enter Command mode
- `h`, `j`, `k`, `l` - Navigate left, down, up, right
- `w` - Move forward one word
- `b` - Move back one word
- `o` - Open a new line below the current line
- `O` - Open a new line above the current line
- `a` - Append text after the cursor
- `A` - Append text at the end of the line
- `i` - Insert text before the cursor
- `I` - Insert text at the beginning of the line
- `x` - Delete a character
- `r` - Replace a character
- `R` - Enter Replace mode
- `dd` - Delete a line
- `2dd` - Delete two lines
- `dw` - Delete to the beginning of the next word
- `de` - Delete to the end of the word
- `d$` - Delete to the end of the line
- `cw` - Change to the beginning of the next word
- `ce` - Change to the end of the word
- `c$` - Change to the end of the line
- `cc` - Change the entire line
- `2w` - Move forward two words
- `3e` - Move to the end of the third word
- `3j` - Move down three lines
- `y` - Yank (copy) text
- `yy` - Yank (copy) a line
- `p` - Paste after the cursor
- `u` - Undo
- `Ctrl+r` - Redo
- `Ctrl+g` - Show file information
- `%` - Jump to matching parentheses
- `:s/old/new/g` - Replace all occurrences of `old` with `new`
- `:s/old/new/gc` - Replace all occurrences of `old` with `new`, with confirmation
- `:s/old/new/gci` - Replace all occurrences of `old` with `new`, case-insensitive
- `:!i<command>` - Run a shell command. For example, `:!ls` to list files in the current directory.
- `:help <topic>` - Open the help documentation for a specific topic. For example, `:help w` for help on the `w` command or `:help user-manual` for the user manual.

## Installed Plugins

This configuration includes several plugins to enhance the editing experience and add new functionality to Neovim.

### 1. [goolord/alpha-nvim](https://github.com/goolord/alpha-nvim)

This plugin provides a customizable greeter for Neovim. It displays a dashboard-like interface when opening a new Neovim instance.

### 2. [catppuccin/nvim](https://github.com/catppuccin/nvim)

This is a color scheme plugin that provides a vibrant and eye-catching color palette for Neovim.

### 3. [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) and [github/copilot.vim](https://github.com/github/copilot.vim)

These plugins provide code completion functionality for Neovim. `cmp-nvim-lsp` is a language server protocol (LSP) completion engine, while `copilot.vim` integrates GitHub's Copilot AI-assisted coding tool.

The following key mappings are used for code completion:

- `<C-b>` - Scroll docs up
- `<C-f>` - Scroll docs down
- `<C-Space>` - Trigger completion
- `<C-e>` - Abort completion
- `<CR>` - Confirm completion selection

### 4. [mfussenegger/nvim-dap](https://github.com/mfussenegger/nvim-dap)

This plugin adds support for debugging in Neovim. It allows you to set breakpoints, step through code, and inspect variables.

The following key mappings are used for debugging:

- `<Leader>dt` - Toggle breakpoint
- `<Leader>dc` - Continue execution
- `<Leader>dx` - Terminate debugging session
- `<Leader>do` - Step over

### 5. [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim)

This plugin is a portable package manager for Neovim and Lua language servers. It simplifies the installation and management of various language servers and tools.

The following key mappings are used for language server integration:

- `K` - Show hover information
- `<Leader>gd` - Go to definition
- `<Leader>gr` - Find references
- `<Leader>ca` - Code action

### 6. [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)

This plugin provides a customizable status line for Neovim.

### 7. [iamcco/markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)

This plugin adds live preview functionality for Markdown files in Neovim.

The following key mapping is used for Markdown preview:

- `<Leader>cp` - Toggle Markdown preview

### 8. [nvim-neo-tree/neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)

This plugin provides a file explorer sidebar for Neovim.

The following key mapping is used to open the file explorer:

- `<C-n>` - Open/close file explorer

### 9. [jose-elias-alvarez/null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim)

This plugin integrates various code formatters, linters, and other tools into Neovim's built-in language server protocol (LSP).

The following key mapping is used for code formatting:

- `<Leader>gf` - Format code

### 10. [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

This plugin provides a fuzzy finder interface for Neovim, allowing you to search and navigate files, buffers, and more.

This plugin requires the installation of the tools `ripgrep` and `fd` for live grep functionality and file finding. On MacOS, these can be installed using Homebrew:

```bash
brew install ripgrep fd
```

The following key mappings are used for Telescope:

- `<C-p>` - Find files
- `<Leader>fg` - Live grep

### 11. [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

This plugin is a syntax highlighting engine for Neovim, providing better syntax highlighting and additional features like code folding and indentation guides.

### 12. git stuff [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive) && [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)

These plugins provide Git integration for Neovim, allowing you to view Git status, commit changes, and navigate through Git history.

The following key mappings are used for Git integration:

- `<Leader>gp` - Git preview hunk
- `<Leader>gt` - Git toggle current line blame
- Also run `:Git` to run git commands, for example `:Git status`


## Plugin Health

To check the health of the installed plugins, you can run the following command in Neovim:

```vim
:checkhealth <plugin-name>
```

So for example, to check the health of the `telecope.nvim` plugin, you would run:

```vim
:checkhealth telescope
```

Which will provide information about the plugin's configuration and any issues that may need to be addressed.

## Cheatsheet

Below is a cheatsheet of the key mappings provided by this configuration. 

Note: 
- `<Leader>` is mapped to the space key.
- `<C-...>` refers to the Control key combined with another key.

| Mapping            | Action                        |
|--------------------|---------------------------------|
| `<C-b>`            | Scroll docs up (completion)    |
| `<C-f>`            | Scroll docs down (completion)  |
| `<C-Space>`        | Trigger completion             |
| `<C-e>`            | Abort completion               |
| `<CR>`             | Confirm completion selection   |
| `<Leader>dt`       | Toggle breakpoint              |
| `<Leader>dc`       | Continue execution             |
| `<Leader>dx`       | Terminate debugging session    |
| `<Leader>do`       | Step over                      |
| `K`                | Show hover information         |
| `<Leader>gd`       | Go to definition               |
| `<Leader>gr`       | Find references                |
| `<Leader>ca`       | Code action                    |
| `<Leader>cp`       | Toggle Markdown preview        |
| `<C-n>`            | Open/close file explorer       |
| `<Leader>gf`       | Format code                    |
| `<C-p>`            | Find files (Telescope)         |
| `<Leader>fg`       | Live grep (Telescope)          |
| `<Leader>gp`       | Git preview hunk               |
| `<Leader>gt`       | Git toggle current line blame  |
