{ ... }:
{
  plugins.alpha = {
    enable = true;
    settings = {
      layout = [
        {
          type = "padding";
          val = 2;
        }
        {
          opts = {
            hl = "Type";
            position = "center";
          };
          type = "text";
          val = [
            "███╗   ██╗██╗██╗  ██╗██╗   ██╗██╗███╗   ███╗"
            "████╗  ██║██║╚██╗██╔╝██║   ██║██║████╗ ████║"
            "██╔██╗ ██║██║ ╚███╔╝ ██║   ██║██║██╔████╔██║"
            "██║╚██╗██║██║ ██╔██╗ ╚██╗ ██╔╝██║██║╚██╔╝██║"
            "██║ ╚████║██║██╔╝ ██╗ ╚████╔╝ ██║██║ ╚═╝ ██║"
            "╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝"
          ];
        }
        {
          type = "padding";
          val = 2;
        }
        {
          type = "group";
          val = [
            {
              on_press = {
                __raw = "function() vim.cmd[[ene]] end";
              };
              opts = {
                shortcut = "n";
                position = "center";
                align_shortcut = "right";
                cursor = 3;
                width = 50;
                hl_shortcut = "Keyword";
                keymap = [
                  "n"
                  "n"
                  "<cmd>ene<CR>"
                ];
              };
              type = "button";
              val = "  New file";
            }
            {
              on_press = {
                __raw = ''function() require("telescope.builtin").find_files() end'';
              };
              opts = {
                shortcut = "f";
                position = "center";
                align_shortcut = "right";
                cursor = 3;
                width = 50;
                hl_shortcut = "Keyword";
                keymap = [
                  "n"
                  "f"
                  ''<cmd>lua require("telescope.builtin").find_files()<CR>''
                ];
              };
              type = "button";
              val = "  Find files";
            }
            {
              on_press = {
                __raw = ''function() require("telescope.builtin").oldfiles() end'';
              };
              opts = {
                shortcut = "r";
                position = "center";
                align_shortcut = "right";
                cursor = 3;
                width = 50;
                hl_shortcut = "Keyword";
                keymap = [
                  "n"
                  "r"
                  ''<cmd>lua require("telescope.builtin").oldfiles()<CR>''
                ];
              };
              type = "button";
              val = "  Recent files";
            }
            {
              on_press = {
                __raw = ''function() require("telescope.builtin").live_grep() end'';
              };
              opts = {
                shortcut = "g";
                position = "center";
                align_shortcut = "right";
                cursor = 3;
                width = 50;
                hl_shortcut = "Keyword";
                keymap = [
                  "n"
                  "g"
                  ''<cmd>lua require("telescope.builtin").live_grep()<CR>''
                ];
              };
              type = "button";
              val = "  Find text";
            }
            {
              on_press = {
                __raw = ''function() require("orgmode").action("agenda.open_by_key", "p") end'';
              };
              opts = {
                shortcut = "a";
                position = "center";
                align_shortcut = "right";
                cursor = 3;
                width = 50;
                hl_shortcut = "Keyword";
                keymap = [
                  "n"
                  "a"
                  ''<cmd>lua require("orgmode").action("agenda.open_by_key", "p")<CR>''
                ];
              };
              type = "button";
              val = "󰕪  Org Agenda";
            }
            {
              on_press = {
                __raw = ''function() vim.cmd[[call feedkeys(",rf")]] end'';
              };
              opts = {
                shortcut = "r";
                position = "center";
                align_shortcut = "right";
                cursor = 3;
                width = 50;
                hl_shortcut = "Keyword";
                keymap = [
                  "n"
                  "r"
                  ''<cmd>call feedkeys(",rf")<CR>''
                ];
              };
              type = "button";
              val = "  Org Roam";
            }
            {
              on_press = {
                __raw = ''function() require("telescope.builtin").find_files({cwd=vim.fs.normalize("~/.config/nix-configs")}) end'';
              };
              opts = {
                shortcut = "c";
                position = "center";
                align_shortcut = "right";
                cursor = 3;
                width = 50;
                hl_shortcut = "Keyword";
                keymap = [
                  "n"
                  "c"
                  ''<cmd>lua require("telescope.builtin").find_files({cwd=vim.fs.normalize("~/.config/nix-configs")})<CR>''
                ];
              };
              type = "button";
              val = "  Nix config";
            }
            {
              on_press = {
                __raw = ''function() require("persistence").load() end'';
              };
              opts = {
                shortcut = "s";
                position = "center";
                align_shortcut = "right";
                cursor = 3;
                width = 50;
                hl_shortcut = "Keyword";
                keymap = [
                  "n"
                  "s"
                  ''<cmd>lua require("persistence").load()<CR>''
                ];
              };
              type = "button";
              val = "  Restore session";
            }
            {
              on_press = {
                __raw = "function() vim.cmd[[qa]] end";
              };
              opts = {
                shortcut = "q";
                position = "center";
                align_shortcut = "right";
                cursor = 3;
                width = 50;
                hl_shortcut = "Keyword";
                keymap = [
                  "n"
                  "q"
                  "<cmd>quit<CR>"
                ];
              };
              type = "button";
              val = "  Quit Neovim";
            }
          ];
        }
        {
          type = "padding";
          val = 2;
        }
        {
          opts = {
            hl = "Keyword";
            position = "center";
          };
          type = "text";
          val = "Very inspiring quote here.";
        }
      ];
    };
  };
}
