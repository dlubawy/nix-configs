{ ... }:
{
  plugins.cmp = {
    enable = true;
    autoEnableSources = true;
    settings = {
      completion.completeopt = "menu,menuone,noinsert";
      snippet.expand = ''
        function(args)
            require("luasnip").lsp_expand(args.body)
        end
      '';
      mapping = {
        __raw = ''
          cmp.mapping.preset.insert({
              ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
              ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
              ["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          })
        '';
      };
      sources = [
        { name = "copilot"; }
        { name = "nvim_lsp"; }
        { name = "luasnip"; }
        { name = "path"; }
        { name = "buffer"; }
        { name = "neorg"; }
      ];
      experimental = {
        ghost_text = {
          hl_group = "CmpGhostText";
        };
      };
    };
  };
}
