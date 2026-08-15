{
  pkgs,
  lib,
  config,
  inputs,
  modulesPath,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  imports = [
    "${modulesPath}/programs/neovim"
    inputs.nixvim.homeModules.nixvim
  ];

  programs = {
    nixvim = lib.mkMerge [
      (mkIf (!config.minimal) (import ../nixvim))
      {
        enable = true;
        defaultEditor = true;
        vimdiffAlias = true;
        nixpkgs.source =
          if pkgs.stdenv.hostPlatform.isDarwin then inputs.nixpkgs-darwin else inputs.nixpkgs;
      }
    ];
  };

  launchd.agents = lib.mkIf (pkgs.stdenv.isDarwin && config.gui.enable) {
    orgmode = {
      enable = true;
      config =
        let
          orgmodeScript = pkgs.writeShellScriptBin "org_cron" ''
            ${config.programs.nixvim.build.package.outPath}/bin/nvim --noplugin --headless -c 'lua require("partials.org_cron")'
          '';
        in
        {
          StartCalendarInterval = { };
          Program = "${orgmodeScript}/bin/org_cron";
        };
    };
  };
}
