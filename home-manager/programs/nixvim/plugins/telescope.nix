{
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
}
