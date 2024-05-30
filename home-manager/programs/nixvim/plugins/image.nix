{ pkgs, ... }:
{
  enable = true;
  backend = "${if pkgs.stdenv.isDarwin then "kitty" else "ueberzug"}";
  integrations = {
    markdown = {
      enabled = true;
      clearInInsertMode = true;
    };
    neorg = {
      enabled = true;
      clearInInsertMode = true;
    };
  };
}
