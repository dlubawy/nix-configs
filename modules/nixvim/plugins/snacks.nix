{ pkgs, ... }:
{
  extraPackages = with pkgs; [
    tectonic
    ghostscript
    mermaid-cli
  ];
  plugins = {
    snacks = {
      enable = true;
      settings = {
        image.enable = true;
      };
    };
  };
}
