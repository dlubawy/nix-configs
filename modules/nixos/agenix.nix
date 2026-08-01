{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.agenix;
in
{
  options = {
    agenix = {
      hostKeys = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [
          {
            type = "pq";
            path = "/etc/agenix/age_host_pq_key";
          }
        ];
        example = [
          {
            type = "pq";
            path = "/etc/agenix/age_host_pq_key";
          }
          {
            type = "x25519";
            path = "/etc/agenix/age_host_x25519_key";
          }
        ];
        description = ''
          NixOS can automatically generate agenix host keys.  This option
          specifies the path, type and location of each key.
        '';
      };

      generateHostKeys = lib.mkOption {
        type = lib.types.bool;
        default = (builtins.length (builtins.attrNames config.age.secrets) > 0);
        defaultText = lib.literalExpression "(builtins.length (builtins.attrNames config.age.secrets) > 0)";
        description = ''
          Whether to generate agenix host keys.

          This can be enabled explicitly if you want to generate host keys but
          don't want to have secrets enabled in agenix.
        '';
        example = true;
      };
    };
  };
  config = {
    assertions = [
      {
        assertion = (builtins.all (x: x) (map (k: k.type == "pq" || k.type == "x25519") cfg.hostKeys));
        message = "Host key type can only be one of 'x25519' or 'pq'";
      }
    ];
    systemd.services.agenix-keygen = {
      description = "agenix host keys generation";
      wantedBy = [ "multi-user.target" ];
      unitConfig = {
        ConditionFileNotEmpty = map (k: "|!${k.path}") cfg.hostKeys;
      };
      serviceConfig = {
        Type = "oneshot";
      };
      path = [ pkgs.age ];
      script = lib.flip lib.concatMapStrings cfg.hostKeys (k: ''
        if ! [ -s "${k.path}" ]; then
            if ! [ -h "${k.path}" ]; then
                rm -f "${k.path}"
            fi
            mkdir -p "$(dirname '${k.path}')"
            chmod 0755 "$(dirname '${k.path}')"
            age-keygen \
              ${lib.optionalString ((k ? type) && k.type == "pq") "-pq"} \
              -o "${k.path}"
        fi
      '');
    };
  };
}
