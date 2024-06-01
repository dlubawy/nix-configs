{ ... }:
{
  plugins.which-key = {
    enable = true;
    registrations = {
      mode = [
        "n"
        "v"
      ];
      g = {
        name = "+goto";
        R = [
          ''<cmd>lua require("trouble").toggle("lsp_reference")<CR>''
          "LSP Reference"
        ];
        s = {
          name = "+surround";
        };
      };
      "]" = {
        name = "+next";
        "]" = "Next Reference";
        t = [
          ''<cmd>lua require("todo-comments").jump_next()<CR>''
          "Next todo comment"
        ];
        b = [
          ''<cmd>BufferLineCycleNext<CR>''
          "Next buffer"
        ];
      };
      "[" = {
        name = "+prev";
        "[" = "Prev Reference";
        t = [
          ''<cmd>lua require("todo-comments").jump_prev()<CR>''
          "Previous todo comment"
        ];
        b = [
          ''<cmd>BufferLineCyclePrev<CR>''
          "Prev buffer"
        ];
      };
      "<S-l>" = [
        ''<cmd>BufferLineCycleNext''
        "Next buffer"
      ];
      "<S-h>" = [
        ''<cmd>BufferLineCyclePrev''
        "Prev buffer"
      ];
      "<leader>" = {
        "," = [
          ''<cmd>lua require("telescope.builtin").buffers({sort_mru=true, sort_lastused=true})<CR>''
          "Switch Buffer"
        ];
        m = [
          "<cmd>MundoToggle<CR>"
          "Mundo Toggle"
        ];
        "<tab>" = {
          name = "+tabs";
        };
        b = {
          name = "+buffer";
          p = [
            ''<cmd>BufferLineTogglePin<CR>''
            "Toggle pin"
          ];
          P = [
            ''<cmd>BufferLineGroupClose ungrouped<CR>''
            "Delete non-pinned buffers"
          ];
          o = [
            ''<cmd>BufferLineCloseOthers<CR>''
            "Delete other buffers"
          ];
          r = [
            ''<cmd>BufferLineCloseRight<CR>''
            "Delete buffers to the right"
          ];
          l = [
            ''<cmd>BufferLineCloseLeft<CR>''
            "Delete buffers to the left"
          ];
        };
        c = {
          name = "+code";
          d = [
            "<cmd>cd %:p:h<CR><cmd>pwd<CR>"
            "Change Directory"
          ];
          l = [
            "<cmd>LspInfo<CR>"
            "Lsp Info"
          ];
          a = [
            "<cmd>lua vim.lsp.buf.code_action()<CR>"
            "Code Action"
          ];
        };
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
          n = [
            "<cmd>enew<CR>"
            "New File"
          ];
        };
        g = {
          name = "+git";
          S = [
            ''<cmd>lua require("gitsigns").stage_buffer()<CR>''
            "Stage Buffer"
          ];
          R = [
            ''<cmd>lua require("gitsigns").reset_buffer()<CR>''
            "Reset Buffer"
          ];
          b = [
            ''<cmd>lua require("gitsigns").blame_line({full=true})<CR>''
            "Blame Line"
          ];
          d = [
            ''<cmd>lua require("gitsigns").diffthis()<CR>''
            "Diff This"
          ];
          D = [
            ''<cmd>lua require("gitsigns").diffthis("~")''
            "Diff ~"
          ];
          h = {
            name = "+hunks";
            s = [
              ''<cmd>lua require("gitsigns").stage_hunk()<CR>''
              "Stage Hunk"
            ];
            r = [
              ''<cmd>lua require("gitsigns").reset_hunk()<CR>''
              "Reset Hunk"
            ];
            u = [
              ''<cmd>lua require("gitsigns").undo_stage_hunk()<CR>''
              "Undo Stage Hunk"
            ];
            p = [
              ''<cmd>lua require("gitsigns").preview_hunk()<CR>''
              "Preview Hunk"
            ];
          };
          t = {
            name = "+toggle";
            b = [
              ''<cmd>lua require("gitsigns").toggle_current_line_blame()<CR>''
              "Toggle Line Blame"
            ];
            d = [
              ''<cmd>lua require("gitsigns").toggle_deleted()<CR>''
              "Toggle Deleted"
            ];
          };
        };
        q = {
          name = "+quit/session";
          a = [
            "<cmd>qa<CR>"
            "Quit"
          ];
          s = [
            ''<cmd>lua require("persistence").load()<CR>''
            "Restore Session"
          ];
          l = [
            ''<cmd>lua require("persistence").load({last=true})<CR>''
            "Restore Last Session"
          ];
          qq = [
            ''<cmd>lua require("persistence").stop()<CR>''
            "Stop Persistence"
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
          r = [
            ''<cmd>lua require("spectre").open()<CR>''
            "Replace in files (Spectre)"
          ];
          n = {
            name = "+noice";
          };
          t = [
            ''<cmd>TodoTelescope<CR>''
            "Todo"
          ];
          T = [
            ''<cmd>TodoTelescope keywords=TODO,FIX,FIXME<CR>''
            "Todo/Fix/Fixme"
          ];
        };
        u = {
          name = "+ui";
          c = [
            ''<cmd>lua require("telescope.builtin").colorscheme({enable_preview=true})<CR>''
            "Colorscheme with preview"
          ];
          n = [
            ''<cmd>lua require("notify").dismiss({silent=true, pending=true})<CR>''
            "Dismiss all Notifications"
          ];
        };
        w = {
          name = "+windows";
        };
        x = {
          name = "+diagnostics/quickfix";
          x = [
            ''<cmd>lua require("trouble").toggle()<CR>''
            "Trouble"
          ];
          w = [
            ''<cmd>lua require("trouble").toggle("workspace_diagnostics")<CR>''
            "Workspace Diagnostics"
          ];
          d = [
            ''<cmd>lua require("trouble").toggle("document_diagnostics")<CR>''
            "Document Diagnostics"
          ];
          q = [
            ''<cmd>lua require("trouble").toggle("quickfix")<CR>''
            "Quickfix"
          ];
          l = [
            ''<cmd>lua require("trouble").toggle("loclist")<CR>''
            "Location List"
          ];
          t = [
            ''<cmd>TodoTrouble<CR>''
            "Todo (Trouble)"
          ];
          T = [
            ''<cmd>TodoTrouble keywords=TODO,FIX,FIXME<CR>''
            "Todo/Fix/Fixme (Trouble)"
          ];
        };
        n = {
          name = "+neorg";
          n = [
            ''<cmd>Neorg<CR>''
            "Neorg"
          ];
          j = [
            ''<cmd>Neorg journal<CR>''
            "Neorg journal"
          ];
          i = [
            ''<cmd>Neorg index<CR>''
            "Neorg index"
          ];
          c = [
            ''<cmd>Neorg capture<CR>''
            "Neorg capture"
          ];
        };
      };
    };
    plugins.spelling.enabled = true;
  };
}
