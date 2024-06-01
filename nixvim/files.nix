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
      keymaps = [
        {
          key = "<localleader>p";
          action = "<cmd>MarkdownPreviewToggle<CR>";
          options.desc = "Markdown Preview";
        }
      ];
    };
  };
}
