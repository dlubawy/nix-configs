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
        vim.cmd("Neorg module load core.concealer")
      '';
    };
    "ftplugin/markdown.lua" = {
      extraConfigLua = ''
        WhichKeyMarkdown()
      '';
    };
  };
}
