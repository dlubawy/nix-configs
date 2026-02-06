{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./files.nix
    ./config.nix
    ./keymaps.nix
    ./autoCmd.nix
    ./plugins
  ];

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

    # orgmode
    conceallevel = 2;
    concealcursor = "nc";
  };

  globals = {
    mapleader = ",";
    maplocalleader = "\\";
    html_indent_inctags = "hmtl,body,head,tbody";
    rbql_with_headers = 1;
  };

  extraConfigLua = ''
    vim.cmd("hi CursorLine cterm=none ctermbg=0 ctermfg=none")
  '';

  extraPackages =
    with pkgs;
    [
      fd
      fzf
      gawk
      gnused
      nodePackages.prettier
      python313Packages.pylatexenc
      ripgrep
      stylua
    ]
    ++ (lib.optionals (pkgs.stdenv.isDarwin) [
      (pkgs.writeShellScriptBin "gsed" "exec ${pkgs.gnused}/bin/sed \"$@\"")
    ]);

  extraPlugins = with pkgs.vimPlugins; [
    vim-mundo
    rainbow_csv
    vim-table-mode
  ];

  plugins = {
    # Coding
    cmp-nvim-lsp.enable = true;
    cmp-buffer.enable = true;
    cmp-path.enable = true;
    cmp-cmdline.enable = true;
    luasnip.enable = true;
    friendly-snippets.enable = true;
    cmp_luasnip.enable = true;
    nvim-autopairs.enable = true;
    comment.enable = true;
    lspkind = {
      enable = true;
      settings = {
        symbolMap = {
          Copilot = "";
        };
      };
    };
    fzf-lua.enable = true;

    # Editor
    neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        filesystem.follow_current_file.enabled = true;
      };
    };
    spectre = {
      enable = true;
      settings.open_cmd = "noswapfile vnew";
    };
    gitsigns.enable = true;
    illuminate = {
      enable = true;
      settings = {
        delay = 200;
        largeFileCutoff = 2000;
        largeFileOverrides.providers = [ "lsp" ];
      };
    };
    todo-comments.enable = true;
    fugitive.enable = true;
    markdown-preview.enable = true;
    render-markdown.enable = true;
    lastplace.enable = true;

    # Linting
    lint = {
      enable = true;
      lintersByFt = {
        sql = [ "sqlfluff" ];
      };
    };

    # Neorg
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
      settings = {
        indent.enable = true;
        highlight = {
          enable = true;
          disable = [ "csv" ];
        };
      };
      grammarPackages = config.plugins.treesitter.package.passthru.allGrammars ++ [
        pkgs.tree-sitter-grammars.tree-sitter-org-nvim
        pkgs.tree-sitter-grammars.tree-sitter-norg-meta
      ];
    };
    treesitter-context = {
      enable = true;
      settings = {
        mode = "cursor";
        max_lines = 3;
      };
    };
    ts-autotag.enable = true;

    # UI
    web-devicons.enable = true;
    notify.enable = true;
    lualine.enable = true;
    indent-blankline.enable = true;
    snacks = {
      enable = true;
      settings = {
        image.enable = true;
      };
    };

    # Util
    persistence.enable = true;
  };
}
