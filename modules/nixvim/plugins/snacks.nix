{ pkgs, ... }:
{
  extraPackages = builtins.attrValues {
    inherit (pkgs)
      tectonic
      ghostscript
      mermaid-cli
      ;
  };
  plugins = {
    snacks = {
      enable = true;
      settings = {
        image.enable = true;
      };
    };
  };
}
