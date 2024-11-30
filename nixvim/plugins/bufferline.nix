{ ... }:
{
  plugins.bufferline = {
    enable = true;
    settings = {
      options = {
        always_show_bufferline = false;
        diagnostics = "nvim_lsp";
        offsets = [
          {
            filetype = "neo-tree";
            text = "Neo-tree";
            highlight = "Directory";
            text_align = "left";
          }
        ];
      };
    };
  };
  plugins.which-key = {
    # registrations = {
    #   "]" = {
    #     name = "+next";
    #     b = [
    #       ''<cmd>BufferLineCycleNext<CR>''
    #       "Next buffer"
    #     ];
    #   };
    #   "[" = {
    #     name = "+prev";
    #     b = [
    #       ''<cmd>BufferLineCyclePrev<CR>''
    #       "Prev buffer"
    #     ];
    #   };
    #   "<S-l>" = [
    #     ''<cmd>BufferLineCycleNext''
    #     "Next buffer"
    #   ];
    #   "<S-h>" = [
    #     ''<cmd>BufferLineCyclePrev''
    #     "Prev buffer"
    #   ];
    #   "<leader>" = {
    #     b = {
    #       name = "+buffer";
    #       p = [
    #         ''<cmd>BufferLineTogglePin<CR>''
    #         "Toggle pin"
    #       ];
    #       P = [
    #         ''<cmd>BufferLineGroupClose ungrouped<CR>''
    #         "Delete non-pinned buffers"
    #       ];
    #       o = [
    #         ''<cmd>BufferLineCloseOthers<CR>''
    #         "Delete other buffers"
    #       ];
    #       r = [
    #         ''<cmd>BufferLineCloseRight<CR>''
    #         "Delete buffers to the right"
    #       ];
    #       l = [
    #         ''<cmd>BufferLineCloseLeft<CR>''
    #         "Delete buffers to the left"
    #       ];
    #     };
    #   };
    # };
  };
}
