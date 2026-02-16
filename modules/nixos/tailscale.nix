{
  config,
  pkgs,
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
    optionals
    ;
in
{
  options = {
    services = {
      tailscale = {
        bootstrap = {
          enable = mkEnableOption "Bootstrap permanent node with auth key";
          tag = mkOption {
            description = "Tag to apply to node";
            type = types.str;
          };
        };
        ssh.enable = mkEnableOption "Enable Tailscale SSH";
      };

      tsidp.bootstrap = {
        enable = mkEnableOption "Bootstrap permanent node with auth key";
        tag = mkOption {
          description = "Tag to apply to node";
          type = types.str;
          default = "idp";
        };
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
      {
        assertion = config.services.tsidp.bootstrap.enable -> config.services.tsidp.bootstrap.tag != "";
        message = "Must apply tag when bootstrapping permanent tailscale node";
      }
    ];

    age.secrets = {
      tailscale.file = mkDefault ../../secrets/tailscale.age;
    };

    networking.firewall = mkIf config.networking.firewall.enable {
      interfaces = {
        "${config.services.tailscale.interfaceName}" = mkIf config.services.tailscale.ssh.enable {
          allowedTCPPorts = [
            22
          ]
          ++ (optionals config.services.openssh.enable [ 2222 ]);
        };
      };
    };

    services = {
      tailscale = {
        authKeyFile = mkDefault (
          if config.services.tailscale.bootstrap.enable then config.age.secrets.tailscale.path else null
        );
        authKeyParameters = {
          ephemeral = mkDefault (!config.services.tailscale.bootstrap.enable);
        };
        extraUpFlags = [
          "--advertise-tags=tag:${config.services.tailscale.bootstrap.tag}"
        ]
        ++ (optionals config.services.tailscale.ssh.enable [
          "--ssh"
        ]);
      };

      tsidp.environmentFile = "/etc/tsidp";

      openssh.ports = mkIf config.services.tailscale.ssh.enable [ 2222 ];
    };

    systemd = {
      services = {
        tailscaled = {
          after = mkIf (config.systemd.network.wait-online.enable) [
            "systemd-networkd-wait-online.service"
          ];
          serviceConfig.Environment = (
            optionals config.networking.nftables.enable [
              "TS_DEBUG_FIREWALL_MODE=nftables"
            ]
          );
        };

        tsidp-auth = mkIf config.services.tsidp.bootstrap.enable {
          description = "Fetches OAuth token to authenticate tsidp service";
          after = [
            "tsidp.service"
            "tailscaled.service"
          ];
          wants = [
            "tsidp.service"
            "tailscaled.service"
          ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "notify";
          };
          path = builtins.attrValues {
            inherit (pkgs)
              tailscale
              gawk
              jq
              ;
          };
          enableStrictShellChecks = true;
          script = ''
            envFile=${config.services.tsidp.environmentFile}

            isOnline() {
              tailscale status --json | jq -r '[.Peer.[] | (.HostName == "idp" and .Online == true)] | any'
            }

            writeToken() {
              cat > "$envFile" <<EOF
            TS_AUTH_KEY=$1
            EOF
            }

            lastState=""
            while state="$(isOnline)"; do
              if [[ "$state" != "$lastState" ]]; then
                case "$state" in
                  true)
                    echo "idp service is online"
                    systemd-notify --ready
                    exit 0
                    ;;
                  false)
                    echo "idp service is offline, getting auth key"
                    secret=$(cat ${config.age.secrets.tailscale.path})
                    clientID=$(cat ${config.age.secrets.tailscale.path} | awk -F'-' '{print $3}' | tr -d '\n')
                    token=$(env TS_API_CLIENT_ID="$clientID" TS_API_CLIENT_SECRET="$secret" get-authkey -tags tag:${config.services.tsidp.bootstrap.tag})
                    writeToken "$token"
                    systemctl restart tsidp.service
                    ;;
                esac
                echo "Online = $state"
              fi
              lastState="$state"
              sleep .5
            done
          '';
        };
      };

      tmpfiles.settings.tailscale = mkIf config.services.tsidp.enable {
        "${config.services.tsidp.environmentFile}" = {
          f = {
            user = "root";
            group = "root";
            mode = "600";
          };
        };
      };
    };
  };
}
