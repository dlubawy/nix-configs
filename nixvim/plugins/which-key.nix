{ ... }:
{
  plugins.which-key = {
    enable = true;
    # registrations = {
    #   mode = [
    #     "n"
    #     "v"
    #   ];
    #   z = {
    #     name = "+folds";
    #   };
    #   g = {
    #     name = "+goto";
    #     R = [
    #       ''<cmd>lua require("trouble").toggle("lsp_reference")<CR>''
    #       "LSP Reference"
    #     ];
    #     s = {
    #       name = "+surround";
    #     };
    #   };
    #   "]" = {
    #     name = "+next";
    #     "]" = "Next Reference";
    #     t = [
    #       ''<cmd>lua require("todo-comments").jump_next()<CR>''
    #       "Next todo comment"
    #     ];
    #   };
    #   "[" = {
    #     name = "+prev";
    #     "[" = "Prev Reference";
    #     t = [
    #       ''<cmd>lua require("todo-comments").jump_prev()<CR>''
    #       "Previous todo comment"
    #     ];
    #   };
    #   "<leader>" = {
    #     m = [
    #       "<cmd>MundoToggle<CR>"
    #       "Mundo Toggle"
    #     ];
    #     "<tab>" = {
    #       name = "+tabs";
    #     };
    #     c = {
    #       name = "+code";
    #       d = [
    #         "<cmd>cd %:p:h<CR><cmd>pwd<CR>"
    #         "Change Directory"
    #       ];
    #       l = [
    #         "<cmd>LspInfo<CR>"
    #         "Lsp Info"
    #       ];
    #       a = [
    #         "<cmd>lua vim.lsp.buf.code_action()<CR>"
    #         "Code Action"
    #       ];
    #     };
    #     f = {
    #       name = "+file/find";
    #       n = [
    #         "<cmd>enew<CR>"
    #         "New File"
    #       ];
    #     };
    #     g = {
    #       name = "+git";
    #       S = [
    #         ''<cmd>lua require("gitsigns").stage_buffer()<CR>''
    #         "Stage Buffer"
    #       ];
    #       R = [
    #         ''<cmd>lua require("gitsigns").reset_buffer()<CR>''
    #         "Reset Buffer"
    #       ];
    #       b = [
    #         ''<cmd>lua require("gitsigns").blame_line({full=true})<CR>''
    #         "Blame Line"
    #       ];
    #       d = [
    #         ''<cmd>lua require("gitsigns").diffthis()<CR>''
    #         "Diff This"
    #       ];
    #       D = [
    #         ''<cmd>lua require("gitsigns").diffthis("~")''
    #         "Diff ~"
    #       ];
    #       h = {
    #         name = "+hunks";
    #         s = [
    #           ''<cmd>lua require("gitsigns").stage_hunk()<CR>''
    #           "Stage Hunk"
    #         ];
    #         r = [
    #           ''<cmd>lua require("gitsigns").reset_hunk()<CR>''
    #           "Reset Hunk"
    #         ];
    #         u = [
    #           ''<cmd>lua require("gitsigns").undo_stage_hunk()<CR>''
    #           "Undo Stage Hunk"
    #         ];
    #         p = [
    #           ''<cmd>lua require("gitsigns").preview_hunk()<CR>''
    #           "Preview Hunk"
    #         ];
    #       };
    #       t = {
    #         name = "+toggle";
    #         b = [
    #           ''<cmd>lua require("gitsigns").toggle_current_line_blame()<CR>''
    #           "Toggle Line Blame"
    #         ];
    #         d = [
    #           ''<cmd>lua require("gitsigns").toggle_deleted()<CR>''
    #           "Toggle Deleted"
    #         ];
    #       };
    #     };
    #     q = {
    #       name = "+quit/session";
    #       a = [
    #         "<cmd>qa<CR>"
    #         "Quit"
    #       ];
    #       s = [
    #         ''<cmd>lua require("persistence").load()<CR>''
    #         "Restore Session"
    #       ];
    #       l = [
    #         ''<cmd>lua require("persistence").load({last=true})<CR>''
    #         "Restore Last Session"
    #       ];
    #       q = {
    #         name = "+persistence";
    #         q = [
    #           ''<cmd>lua require("persistence").stop()<CR>''
    #           "Stop Persistence"
    #         ];
    #       };
    #     };
    #     s = {
    #       name = "+search";
    #       r = [
    #         ''<cmd>lua require("spectre").open()<CR>''
    #         "Replace in files (Spectre)"
    #       ];
    #       n = {
    #         name = "+noice";
    #       };
    #       t = [
    #         ''<cmd>TodoTelescope<CR>''
    #         "Todo"
    #       ];
    #       T = [
    #         ''<cmd>TodoTelescope keywords=TODO,FIX,FIXME<CR>''
    #         "Todo/Fix/Fixme"
    #       ];
    #     };
    #     u = {
    #       name = "+ui";
    #       n = [
    #         ''<cmd>lua require("notify").dismiss({silent=true, pending=true})<CR>''
    #         "Dismiss all Notifications"
    #       ];
    #     };
    #     w = {
    #       name = "+windows";
    #     };
    #     x = {
    #       name = "+diagnostics/quickfix";
    #       x = [
    #         ''<cmd>lua require("trouble").toggle()<CR>''
    #         "Trouble"
    #       ];
    #       w = [
    #         ''<cmd>lua require("trouble").toggle("workspace_diagnostics")<CR>''
    #         "Workspace Diagnostics"
    #       ];
    #       d = [
    #         ''<cmd>lua require("trouble").toggle("document_diagnostics")<CR>''
    #         "Document Diagnostics"
    #       ];
    #       q = [
    #         ''<cmd>lua require("trouble").toggle("quickfix")<CR>''
    #         "Quickfix"
    #       ];
    #       l = [
    #         ''<cmd>lua require("trouble").toggle("loclist")<CR>''
    #         "Location List"
    #       ];
    #       t = [
    #         ''<cmd>TodoTrouble<CR>''
    #         "Todo (Trouble)"
    #       ];
    #       T = [
    #         ''<cmd>TodoTrouble keywords=TODO,FIX,FIXME<CR>''
    #         "Todo/Fix/Fixme (Trouble)"
    #       ];
    #     };
    #     t = {
    #       name = "+tables";
    #     };
    #   };
    # };
    settings.plugins.spelling.enabled = true;
  };
}
