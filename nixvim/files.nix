{ ... }:
{
  files = {
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
      '';
    };
  };
}
