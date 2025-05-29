{
  lib,
  pkgs,
  config,
  ...
}:
let
  systemName = config.systemName;
  nixConfigUsers = config.nix-configs.users;
in
{
  imports = [
    (import ../nix-configs).default
  ];

  config = {
    users.users = lib.concatMapAttrs (name: value: {
      ${name} = {
        isNormalUser = true;
        isTokenUser = true;
        isHidden = false;
        shell = /bin/zsh;
        description = "${value.fullName}";
        initialPassword = "${name}";
      };
    }) nixConfigUsers;

    security = {
      # Allows standard user to run darwin-rebuild through the admin user
      # sudo -Hu ${systemName} darwin-rebuild
      sudo.extraConfig = lib.concatLines (
        lib.concatMap (name: [ "${name} ALL = (${systemName}) ALL" ]) (lib.attrNames nixConfigUsers)
      );
    };

    home-manager.users = lib.concatMapAttrs (name: value: {
      ${name} = {
        gui.enable = true;
        programs.firefox.package = pkgs.firefox-bin;
      };
    }) nixConfigUsers;
  };
}
