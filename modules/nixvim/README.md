# Nixvim Module

This module provides a comprehensive Neovim configuration using nixvim. It transforms Neovim into a full-featured IDE with LSP support, code completion, file navigation, and extensive plugin integrations.

## Purpose

The nixvim module configures Neovim with:

- Language Server Protocol (LSP) integration
- Code completion and snippets
- File navigation and fuzzy finding
- Git integration
- Syntax highlighting and treesitter
- Note-taking (Org-mode and Neorg)
- Code formatting and linting
- Custom keybindings and commands

## Usage

This module is automatically included via the Home Manager module. It's available as `nvim`, `vim`, and `vi` commands.

## Configuration Structure

The configuration is modular and organized into:

- `default.nix`: Core settings, options, and colorscheme (Catppuccin Frappe)
- `config.nix`: Additional configuration and autocommands
- `keymaps.nix`: Custom key mappings
- `autoCmd.nix`: Autocommands for various events
- `files.nix`: Syntax and file type configurations
- `plugins/`: Individual plugin configurations

## Key Features

### Coding

- **LSP**: Language server integration for multiple languages
- **Completion**: nvim-cmp with multiple sources (LSP, buffer, path, snippets)
- **Snippets**: LuaSnip with friendly-snippets
- **Copilot**: GitHub Copilot integration
- **Formatting**: conform.nvim for code formatting
- **Linting**: nvim-lint (configured linters are defined per-filetype in the module)
- **Autopairs**: Automatic bracket/quote pairing

### Editor

- **File Navigation**: neo-tree file explorer with git integration
- **Fuzzy Finding**: Telescope and fzf-lua for searching
- **Git**: Gitsigns for inline git blame and hunks, Fugitive for git commands
- **Syntax**: Treesitter for enhanced syntax highlighting
- **Markdown**: Preview and rendering for markdown files

### UI

- **Colorscheme**: Catppuccin Frappe theme
- **Statusline**: Lualine with custom configuration
- **Bufferline**: Buffer tabs at the top
- **Icons**: Web devicons for file type indicators
- **Indent Guides**: Visual indent markers
- **Startup Screen**: Alpha dashboard

### Note-taking

- **Org-mode**: Full org-mode support with agenda and capture
- **Neorg**: Modern note-taking with org-mode-like syntax
- **Zen Mode**: Distraction-free writing with tmux/alacritty integration

### Plugins

See `plugins/` directory for individual plugin configurations:

- `alpha.nix`: Startup dashboard
- `bufferline.nix`: Buffer tabs
- `cmp.nix`: Code completion
- `conform-nvim.nix`: Code formatting
- `copilot.nix`: GitHub Copilot
- `image.nix`: Image viewing in terminal
- `lsp.nix`: Language servers
- `neorg.nix`: Neorg note-taking
- `orgmode.nix`: Org-mode support
- `telescope.nix`: Fuzzy finder
- `treesitter-textobjects.nix`: Code navigation
- `trouble.nix`: Diagnostics list
- `which-key.nix`: Keybinding hints

## Keybindings

- Leader key: `,`
- Local leader: `\`
- See `which-key.nix` for comprehensive keybinding documentation

## Extra Packages

The module includes additional tools required by plugins:

- fd, fzf, ripgrep: For searching
- prettier, stylua: For formatting
- pylatexenc: For LaTeX in org-mode
- gnused, gawk: For text processing

## Related Documentation

- See [modules/home-manager](../home-manager) for how nixvim integrates with user configuration
- See nixvim documentation: https://nix-community.github.io/nixvim/
