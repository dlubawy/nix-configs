{ pkgs, ... }:
{
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;
  luaLoader.enable = true;

  colorschemes = {
    catppuccin = {
      enable = true;
      settings.flavour = "frappe";
    };
  };

  opts = {
    # Backup Config
    backupdir = {
      __raw = ''vim.fn.stdpath("cache") .. "/backup"'';
    };
    backup = true;
    backupskip = "/tmp/*,/private/tmp/*";
    writebackup = true;

    # Spaces and Tabs
    tabstop = 4;
    softtabstop = 4;
    expandtab = true;
    shiftwidth = 4;

    # UI Config
    number = true;
    cursorline = true;
    encoding = "utf-8";
    showtabline = 2;

    # Folding
    foldenable = true;
    foldlevelstart = 10;
    foldnestmax = 10;
    foldmethod = "indent";

    # mundo
    undofile = true;

    # which-key
    timeout = true;
    timeoutlen = 300;
  };

  globals = {
    mapleader = ",";
    maplocalleader = "\\";
    html_indent_inctags = "hmtl,body,head,tbody";
    rbql_with_headers = 1;
  };

  files = import ./files.nix;

  extraConfigLua = ''
    vim.cmd("hi CursorLine cterm=none ctermbg=0 ctermfg=none")
  '';
  extraConfigLuaPost = import ./configPost.nix;

  keymaps = import ./keymaps.nix;

  autoCmd = import ./autoCmd.nix;

  extraPlugins = with pkgs.vimPlugins; [
    vim-mundo
    (pkgs.vimUtils.buildVimPlugin {
      name = "rainbow_csv";
      src = pkgs.fetchFromGitHub {
        owner = "mechatroner";
        repo = "rainbow_csv";
        rev = "6b914b420fd390103d9d98b3d6a67648ebe59274";
        sha256 = "qhwTALQw0rlruAqpWM3UifF9JEEmwlgCsfFZ7MXq0TQ=";
      };
    })
  ];

  plugins = {
    # Coding
    cmp = import ./plugins/cmp.nix;
    cmp-nvim-lsp.enable = true;
    cmp-buffer.enable = true;
    cmp-path.enable = true;
    cmp-cmdline.enable = true;
    luasnip.enable = true;
    friendly-snippets.enable = true;
    cmp_luasnip.enable = true;
    nvim-autopairs.enable = true;
    comment.enable = true;

    # Editor
    neo-tree = {
      enable = true;
      closeIfLastWindow = true;
      filesystem.followCurrentFile.enabled = true;
    };
    image = import ./plugins/image.nix { inherit pkgs; };
    spectre = {
      enable = true;
      settings.open_cmd = "noswapfile vnew";
    };
    telescope = import ./plugins/telescope.nix;
    which-key = import ./plugins/which-key.nix;
    gitsigns.enable = true;
    illuminate = {
      enable = true;
      delay = 200;
      largeFileCutoff = 2000;
      largeFileOverrides.providers = [ "lsp" ];
    };
    trouble.enable = true;
    todo-comments.enable = true;
    fugitive.enable = true;
    markdown-preview.enable = true;

    # Formatting
    conform-nvim = import ./plugins/conform-nvim.nix;

    # Linting
    lint = {
      enable = true;
      lintersByFt = {
        sql = [ "sqlfluff" ];
      };
    };

    # lsp
    lsp = import ./plugins/lsp.nix;

    # Neorg
    neorg = import ./plugins/neorg.nix;
    zen-mode = {
      enable = true;
      settings.plugins.options = {
        tmux = {
          enabled = true;
        };
        alacritty = {
          enabled = true;
          font = 14;
        };
      };
    };

    # treesitter
    treesitter = {
      enable = true;
      indent = true;

      # NOTE: disable treesitter CSV to allow rainbow_csv
      disabledLanguages = [ "csv" ];
    };
    treesitter-textobjects = import ./plugins/treesitter-textobjects.nix;
    treesitter-context = {
      enable = true;
      settings = {
        mode = "cursor";
        max_lines = 3;
      };
    };
    ts-autotag.enable = true;

    # UI
    notify.enable = true;
    bufferline = import ./plugins/bufferline.nix;
    lualine.enable = true;
    indent-blankline.enable = true;
    alpha = import ./plugins/alpha.nix;

    # Util
    persistence.enable = true;
  };
}
