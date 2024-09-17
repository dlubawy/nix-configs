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
    registrations = {
      "<leader>" = {
        "," = [
          ''<cmd>lua require("telescope.builtin").buffers({sort_mru=true, sort_lastused=true})<CR>''
          "Switch Buffer"
        ];
        f = {
          name = "+file/find";
          b = [
            ''<cmd>require("telescope.builtin").buffers({sort_mru=true, sort_lastused=true})<CR>''
            "Buffers"
          ];
          c = [
            ''<cmd>lua require("telescope.builtin").find_files({cwd=vim.fn.stdpath("config")})<CR>''
            "Find Config File"
          ];
          F = [
            ''<cmd>lua require("telescope.builtin").find_files({cwd=false})<CR>''
            "Find Files (cwd)"
          ];
          R = [
            ''<cmd>require("telescope.builtin").oldfiles({cwd=vim.loop.cwd()})<CR>''
            "Recent (cwd)"
          ];
        };
        s = {
          name = "+search";
          d = [
            ''<cmd>lua require("telescope.builtin").diagnostics({bufnr=0})<CR>''
            "Document Diagnostics"
          ];
          G = [
            ''<cmd>lua require("telescope.builtin").live_grep({cwd=false})<CR>''
            "Grep (cwd)"
          ];
          w = [
            ''<cmd>lua require("telescope.builtin").grep_string({word_match="-w"})<CR>''
            "Word/Selection (root dir)"
          ];
          W = [
            ''<cmd>lua require("telescope.builtin").grep_string({cwd=false, word_match="-w"})<CR>''
            "Word/Selection (cwd)"
          ];
        };
        u = {
          name = "+ui";
          c = [
            ''<cmd>lua require("telescope.builtin").colorscheme({enable_preview=true})<CR>''
            "Colorscheme with preview"
          ];
        };
      };
    };
  };
}
