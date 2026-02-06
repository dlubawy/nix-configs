{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  extraPackages = with pkgs; [
    imagemagick
    luajitPackages.magick
    ueberzugpp
  ];
  plugins.image = {
    # enable = mkDefault lib.nixvim.enableExceptInTests;
    # FIXME: Enable whenever image-nvim is fixed
    enable = false;
    settings = {
      backend = mkDefault "ueberzug";
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
  };
}
