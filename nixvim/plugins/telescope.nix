{ ... }:
{
  plugins.telescope = {
    enable = true;
    extensions = {
      fzf-native = {
        enable = true;
        settings = {
          fuzzy = true;
          override_generic_sorter = true;
          override_file_sorter = true;
          case_mode = "smart_case";
        };
      };
    };
    keymaps = {
      "<leader>/" = {
        action = "live_grep";
        options.desc = "Grep (root dir)";
      };
      "<leader>:" = {
        action = "command_history";
        options.desc = "Command History";
      };
      "<leader>ff" = {
        action = "find_files";
        options.desc = "Find Files (root dir)";
      };
      "<leader>fg" = {
        action = "git_files";
        options.desc = "Find Files (git-files)";
      };
      "<leader>fr" = {
        action = "oldfiles";
        options.desc = "Recent";
      };
      "<leader>gc" = {
        action = "git_commits";
        options.desc = "commits";
      };
      "<leader>gs" = {
        action = "git_status";
        options.desc = "status";
      };
      "<leader>s" = {
        action = "registers";
        options.desc = "Registers";
      };
      "<leader>sa" = {
        action = "autocommands";
        options.desc = "Auto Commands";
      };
      "<leader>sb" = {
        action = "current_buffer_fuzzy_find";
        options.desc = "Buffer";
      };
      "<leader>sc" = {
        action = "command_history";
        options.desc = "Command History";
      };
      "<leader>sC" = {
        action = "commands";
        options.desc = "Commands";
      };
      "<leader>sD" = {
        action = "diagnostics";
        options.desc = "Workspace diagnostics";
      };
      "<leader>sg" = {
        action = "live_grep";
        options.desc = "Grep (root dir)";
      };
      "<leader>sh" = {
        action = "help_tags";
        options.desc = "Help Pages";
      };
      "<leader>sH" = {
        action = "highlights";
        options.desc = "Search Highlight Groups";
      };
      "<leader>sk" = {
        action = "keymaps";
        options.desc = "Key Maps";
      };
      "<leader>sM" = {
        action = "man_pages";
        options.desc = "Man Pages";
      };
      "<leader>sm" = {
        action = "marks";
        options.desc = "Jump to Mark";
      };
      "<leader>so" = {
        action = "vim_options";
        options.desc = "Options";
      };
      "<leader>sR" = {
        action = "resume";
        options.desc = "Resume";
      };
    };
  };
  plugins.which-key = {
    settings.spec = [
      {
        __unkeyed-1 = "<leader>,";
        __unkeyed-2 = ''<cmd>lua require("telescope.builtin").buffers({sort_mru=true, sort_lastused=true})<CR>'';
        desc = "Switch Buffer";
      }
      {
        __unkeyed = "<leader>f";
        group = "file/find";
      }
      {
        __unkeyed-1 = "<leader>fb";
        __unkeyed-2 = ''<cmd>require("telescope.builtin").buffers({sort_mru=true, sort_lastused=true})<CR>'';
        desc = "Buffers";
      }
      {
        __unkeyed-1 = "<leader>fc";
        __unkeyed-2 = ''<cmd>lua require("telescope.builtin").find_files({cwd=vim.fn.stdpath("config")})<CR>'';
        desc = "Find Config File";
      }
      {
        __unkeyed-1 = "<leader>fF";
        __unkeyed-2 = ''<cmd>lua require("telescope.builtin").find_files({cwd=false})<CR>'';
        desc = "Find Files (cwd)";
      }
      {
        __unkeyed-1 = "<leader>fR";
        __unkeyed-2 = ''<cmd>require("telescope.builtin").oldfiles({cwd=vim.loop.cwd()})<CR>'';
        desc = "Recent (cwd)";
      }
      {
        __unkeyed = "<leader>s";
        group = "search";
      }
      {
        __unkeyed-1 = "<leader>sd";
        __unkeyed-2 = ''<cmd>lua require("telescope.builtin").diagnostics({bufnr=0})<CR>'';
        desc = "Document Diagnostics";
      }
      {
        __unkeyed-1 = "<leader>sG";
        __unkeyed-2 = ''<cmd>lua require("telescope.builtin").live_grep({cwd=false})<CR>'';
        desc = "Grep (cwd)";
      }
      {
        __unkeyed-1 = "<leader>sw";
        __unkeyed-2 = ''<cmd>lua require("telescope.builtin").grep_string({word_match="-w"})<CR>'';
        desc = "Word/Selection (root dir)";
      }
      {
        __unkeyed-1 = "<leader>sW";
        __unkeyed-2 = ''<cmd>lua require("telescope.builtin").grep_string({cwd=false, word_match="-w"})<CR>'';
        desc = "Word/Selection (cwd)";
      }
      {
        __unkeyed = "<leader>u";
        group = "ui";
      }
      {
        __unkeyed-1 = "<leader>uc";
        __unkeyed-2 = ''<cmd>lua require("telescope.builtin").colorscheme({enable_preview=true})<CR>'';
        desc = "Colorscheme with preview";
      }
    ];
  };
}
