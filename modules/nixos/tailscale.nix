{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkDefault
    mkOption
    types
    ;
in
{
  options = {
    services.tailscale.bootstrap = {
      enable = mkEnableOption "Bootstrap permanent node with auth key";
      tag = mkOption {
        description = "Tag to apply to node";
        type = types.str;
      };
      ageEncryptedAuthKeyFile = mkOption {
        description = "age encrypted auth key file for bootstrapping node. Must have ownership of tag being applied.";
        type = types.path;
        default = ../../secrets/tailscale.age;
      };
    };
  };

  config = mkIf config.services.tailscale.enable {
    assertions = [
      {
        assertion =
          config.services.tailscale.bootstrap.enable -> config.services.tailscale.bootstrap.tag != "";
        message = "Must apply tag when bootstrapping permanent tailscale node";
      }
    ];

    age.secrets = {
      tailscale.file = mkDefault config.services.tailscale.bootstrap.ageEncryptedAuthKeyFile;
    };

    services.tailscale = {
      authKeyFile = mkDefault (
        if config.services.tailscale.bootstrap.enable then config.age.secrets.tailscale.path else null
      );
      authKeyParameters = {
        ephemeral = mkDefault (!config.services.tailscale.bootstrap.enable);
      };
      extraUpFlags = [
        "--advertise-tags=tag:${config.services.tailscale.bootstrap.tag}"
      ];
    };
  };
}
