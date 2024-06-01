{ ... }:
{
  files = {
    "ftplugin/sql.lua" = {
      extraConfigLua = ''
        WhichKeySQL()
      '';
    };
    "ftplugin/neorg.lua" = {
      extraConfigLua = ''
        WhichKeyNeorg()
      '';
    };
    "ftplugin/markdown.lua" = {
      extraConfigLua = ''
        WhichKeyMarkdown()
      '';
    };
  };
}
