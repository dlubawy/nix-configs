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
    settings.spec = [
      {
        __unkeyed-1 = "]b";
        __unkeyed-2 = "<cmd>BufferLineCycleNext<CR>";
        desc = "Next buffer";
      }
      {
        __unkeyed-1 = "[b";
        __unkeyed-2 = "<cmd>BufferLineCyclePrev<CR>";
        desc = "Prev buffer";
      }
      {
        __unkeyed-1 = "<S-l>";
        __unkeyed-2 = "<cmd>BufferLineCycleNext";
        desc = "Next buffer";
      }
      {
        __unkeyed-1 = "<S-h>";
        __unkeyed-2 = "<cmd>BufferLineCyclePrev";
        desc = "Prev buffer";
      }
      {
        __unkeyed = "<leader>b";
        group = "buffer";
      }
      {
        __unkeyed-1 = "<leader>bp";
        __unkeyed-2 = "<cmd>BufferLineTogglePin<CR>";
        desc = "Toggle pin";
      }
      {
        __unkeyed-1 = "<leader>bP";
        __unkeyed-2 = "<cmd>BufferLineGroupClose ungrouped<CR>";
        desc = "Delete non-pinned buffers";
      }
      {
        __unkeyed-1 = "<leader>bo";
        __unkeyed-2 = "<cmd>BufferLineCloseOthers<CR>";
        desc = "Delete other buffers";
      }
      {
        __unkeyed-1 = "<leader>br";
        __unkeyed-2 = "<cmd>BufferLineCloseRight<CR>";
        desc = "Delete buffers to the right";
      }
      {
        __unkeyed-1 = "<leader>bl";
        __unkeyed-2 = "<cmd>BufferLineCloseLeft<CR>";
        desc = "Delete buffers to the left";
      }
    ];
  };
}
