{
  pkgs,
  helpers,
  lib,
  ...
}:
{
  extraPackages = with pkgs; [
    imagemagick
    luajitPackages.magick
    ueberzugpp
  ];
  plugins.image = {
    enable = helpers.enableExceptInTests;
    backend = lib.mkDefault "ueberzug";
    integrations = {
      markdown = {
        enabled = true;
        clearInInsertMode = true;
        filetypes = [
          "markdown"
          "vimwiki"
          "org"
        ];
      };
      neorg = {
        enabled = true;
        clearInInsertMode = true;
      };
    };
  };
}
