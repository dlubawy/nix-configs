{ ... }:
{
  plugins.which-key = {
    enable = true;
    settings = {
      spec = [
        {
          __unkeyed = [
            {
              __unkeyed = "z";
              group = "folds";
            }
            {
              __unkeyed = "g";
              group = "goto";
            }
            {
              __unkeyed-1 = "gR";
              __unkeyed-2 = ''<cmd>lua require("trouble").toggle("lsp_reference")<CR>'';
              desc = "LSP Reference";
            }
            {
              __unkeyed-1 = "gs";
              group = "surround";
            }
            {
              __unkeyed = "]";
              group = "next";
            }
            {
              __unkeyed = "]]";
              desc = "Next Reference";
            }
            {
              __unkeyed-1 = "]t";
              __unkeyed-2 = ''<cmd>lua require("todo-comments").jump_next()<CR>'';
              desc = "Next todo comment";
            }
            {
              __unkeyed = "[";
              group = "prev";
            }
            {
              __unkeyed = "[[";
              desc = "Prev Reference";
            }
            {
              __unkeyed-1 = "[t";
              __unkeyed-2 = ''<cmd>lua require("todo-comments").jump_prev()<CR>'';
              desc = "Previous todo comment";
            }
            {
              __unkeyed = "<leader>";
              group = "<leader>";
            }
            {
              __unkeyed-1 = "<leader>m";
              __unkeyed-2 = "<cmd>MundoToggle<CR>";
              desc = "Mundo Toggle";
            }
            {
              __unkeyed = "<leader><tab>";
              group = "tabs";
            }
            {
              __unkeyed = "<leader>c";
              group = "code";
            }
            {
              __unkeyed = "<leader>cc";
              group = "CopilotChat";
            }
            {
              __unkeyed-1 = "<leader>cd";
              __unkeyed-2 = "<cmd>cd %:p:h<CR><cmd>pwd<CR>";
              desc = "Change Directory";
            }
            {
              __unkeyed-1 = "<leader>cl";
              __unkeyed-2 = "<cmd>LspInfo<CR>";
              desc = "LSP Info";
            }
            {
              __unkeyed-1 = "<leader>ca";
              __unkeyed-2 = "<cmd>lua vim.lsp.buf.code_action()<CR>";
              desc = "Code Action";
            }
            {
              __unkeyed = "<leader>f";
              group = "file/find";
            }
            {
              __unkeyed-1 = "<leader>fn";
              __unkeyed-2 = "<cmd>enew<CR>";
              desc = "New File";
            }
            {
              __unkeyed = "<leader>g";
              group = "git";
            }
            {
              __unkeyed-1 = "<leader>gS";
              __unkeyed-2 = ''<cmd>lua require("gitsigns").stage_buffer()<CR>'';
              desc = "Stage Buffer";
            }
            {
              __unkeyed-1 = "<leader>gR";
              __unkeyed-2 = ''<cmd>lua require("gitsigns").reset_buffer()<CR>'';
              desc = "Reset Buffer";
            }
            {
              __unkeyed-1 = "<leader>gb";
              __unkeyed-2 = ''<cmd>lua require("gitsigns").blame_line({full=true})<CR>'';
              desc = "Blame Line";
            }
            {
              __unkeyed-1 = "<leader>gd";
              __unkeyed-2 = ''<cmd>lua require("gitsigns").diffthis()<CR>'';
              desc = "Diff This";
            }
            {
              __unkeyed-1 = "<leader>gD";
              __unkeyed-2 = ''<cmd>lua require("gitsigns").diffthis("~")'';
              desc = "Diff ~";
            }
            {
              __unkeyed = "<leader>gh";
              group = "hunks";
            }
            {
              __unkeyed-1 = "<leader>ghs";
              __unkeyed-2 = ''<cmd>lua require("gitsigns").stage_hunk()<CR>'';
              desc = "Stage Hunk";
            }
            {
              __unkeyed-1 = "<leader>ghr";
              __unkeyed-2 = ''<cmd>lua require("gitsigns").reset_hunk()<CR>'';
              desc = "Reset Hunk";
            }
            {
              __unkeyed-1 = "<leader>ghu";
              __unkeyed-2 = ''<cmd>lua require("gitsigns").undo_stage_hunk()<CR>'';
              desc = "Undo Stage Hunk";
            }
            {
              __unkeyed-1 = "<leader>ghp";
              __unkeyed-2 = ''<cmd>lua require("gitsigns").preview_hunk()<CR>'';
              desc = "Preview Hunk";
            }
            {
              __unkeyed = "<leader>gt";
              group = "toggle";
            }
            {
              __unkeyed-1 = "<leader>gtb";
              __unkeyed-2 = ''<cmd>lua require("gitsigns").toggle_current_line_blame()<CR>'';
              desc = "Toggle Line Blame";
            }
            {
              __unkeyed-1 = "<leader>gtd";
              __unkeyed-2 = ''<cmd>lua require("gitsigns").toggle_deleted()<CR>'';
              desc = "Toggle Deleted";
            }
            {
              __unkeyed = "<leader>q";
              group = "quit/session";
            }
            {
              __unkeyed-1 = "<leader>qa";
              __unkeyed-2 = "<cmd>qa<CR>";
              desc = "Quit";
            }
            {
              __unkeyed-1 = "<leader>qs";
              __unkeyed-2 = ''<cmd>lua require("persistence").load()<CR>'';
              desc = "Restore Session";
            }
            {
              __unkeyed-1 = "<leader>ql";
              __unkeyed-2 = ''<cmd>lua require("persistence").load({last=true})<CR>'';
              desc = "Restore Last Session";
            }
            {
              __unkeyed = "<leader>qq";
              group = "persistence";
            }
            {
              __unkeyed-1 = "<leader>qqq";
              __unkeyed-2 = ''<cmd>lua require("persistence").stop()<CR>'';
              desc = "Stop Persistence";
            }
            {
              __unkeyed = "<leader>s";
              group = "search";
            }
            # FIXME: re-enable when ISSUE(#133) is resolved
            # {
            #   __unkeyed-1 = "<leader>sr";
            #   __unkeyed-2 = ''<cmd>lua require("spectre").open()<CR>'';
            #   desc = "Replace in files (Spectre)";
            # }
            {
              __unkeyed = "<leader>sn";
              group = "noice";
            }
            {
              __unkeyed-1 = "<leader>st";
              __unkeyed-2 = "<cmd>TodoTelescope<CR>";
              desc = "Todo";
            }
            {
              __unkeyed-1 = "<leader>sT";
              __unkeyed-2 = "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<CR>";
              desc = "Todo/Fix/Fixme";
            }
            {
              __unkeyed = "<leader>u";
              group = "ui";
            }
            {
              __unkeyed-1 = "<leader>un";
              __unkeyed-2 = ''<cmd>lua require("notify").dismiss({silent=true, pending=true})<CR>'';
              desc = "Dismiss all Notifications";
            }
            {
              __unkeyed = "<leader>w";
              group = "windows";
            }
            {
              __unkeyed = "<leader>x";
              group = "diagnostics/quickfix";
            }
            {
              __unkeyed-1 = "<leader>xx";
              __unkeyed-2 = "<cmd>Trouble diagnostics toggle<CR>";
              desc = "Trouble";
            }
            {
              __unkeyed-1 = "<leader>xw";
              __unkeyed-2 = "<cmd>Trouble diagnostics_workspace toggle<CR>";
              desc = "Workspace Diagnostics";
            }
            {
              __unkeyed-1 = "<leader>xd";
              __unkeyed-2 = "<cmd>Trouble diagnostics_document toggle<CR>";
              desc = "Document Diagnostics";
            }
            {
              __unkeyed-1 = "<leader>xq";
              __unkeyed-2 = "<cmd>Trouble qflist toggle<CR>";
              desc = "Quickfix";
            }
            {
              __unkeyed-1 = "<leader>xl";
              __unkeyed-2 = "<cmd>Trouble loclist toggle<CR>";
              desc = "Location List";
            }
            {
              __unkeyed-1 = "<leader>xt";
              __unkeyed-2 = "<cmd>TodoTrouble<CR>";
              desc = "Todo (Trouble)";
            }
            {
              __unkeyed-1 = "<leader>xT";
              __unkeyed-2 = "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<CR>";
              desc = "Todo/Fix/Fixme (Trouble)";
            }
            {
              __unkeyed = "<leader>t";
              group = "tables";
            }
          ];
          mode = [
            "n"
            "v"
          ];
        }
      ];
      plugins.spelling.enabled = true;
    };
  };
}
