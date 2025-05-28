{ lib, inputs, ... }:
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  programs = {
    nixvim = lib.mkMerge [
      (import ../nixvim)
      {
        enable = true;
        defaultEditor = true;
        vimdiffAlias = true;
      }
    ];
  };
}
