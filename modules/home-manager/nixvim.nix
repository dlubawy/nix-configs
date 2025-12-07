{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

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
