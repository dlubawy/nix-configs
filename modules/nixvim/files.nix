{ ... }:
{
  files = {
    "ftplugin/nix.lua" = {
      extraConfigLua = ''
        vim.o.shiftwidth = 2
        vim.o.softtabstop = 2
        vim.o.expandtab = true
      '';
    };
    "ftplugin/sql.lua" = {
      extraConfigLua = ''
        WhichKeySQL()
      '';
    };
    "ftplugin/norg.lua" = {
      extraConfigLua = ''
        WhichKeyNorg()
        vim.g.table_mode_corner = "|"
        vim.cmd("TableModeEnable")
      '';
    };
    "ftplugin/markdown.lua" = {
      extraConfigLua = ''
        WhichKeyMarkdown()
      '';
    };
    "ftplugin/org.lua" = {
      extraConfigLua = ''
        vim.cmd("TableModeEnable")
        vim.keymap.set('i', '<F2>', '<cmd>lua require("orgmode").action("org_mappings.meta_return")<CR>', {
          silent = true,
          buffer = true,
        })
      '';
    };
  };
}
