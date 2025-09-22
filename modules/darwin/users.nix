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
        name = value.name;
        isNormalUser = true;
        isTokenUser = true;
        isHidden = false;
        shell = /bin/zsh;
        description = value.fullName;
        initialPassword = value.name;
      };
    }) nixConfigUsers;

    security = {
      # Allows standard user to run darwin-rebuild through the admin user
      # sudo -Hu ${systemName} darwin-rebuild
      sudo.extraConfig = lib.concatLines (
        lib.concatMap (user: [ "${user.name} ALL = (${systemName}) ALL" ]) (lib.attrValues nixConfigUsers)
      );
    };

    home-manager.users = lib.concatMapAttrs (name: _: {
      ${name} = {
        home.packages = with pkgs; [
          codex-universal
        ];
        gui.enable = true;
        targets.darwin.defaults = {
          NSGlobalDomain = {
            "com.apple.swipescrolldirection" = false;
            NSDocumentSaveNewDocumentsToCloud = false;
          };
          "com.apple.dock" = {
            autohide = false;
            largesize = 72;
            tilesize = 48;
            magnification = true;
            mineffect = "genie";
            orientation = "bottom";
            showhidden = false;
            show-recents = false;
          };
          "com.apple.finder" = {
            QuitMenuItem = false;
          };
          "com.apple.screensaver" = {
            askForPassword = true;
            askForPasswordDelay = 0;
          };
          "com.apple.AppleMultitouchTrackpad" = {
            Clicking = true;
            TrackpadRightClick = true;
          };
        };
      };
    }) nixConfigUsers;
  };
}
