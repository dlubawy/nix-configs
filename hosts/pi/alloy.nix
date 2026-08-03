{
  pkgs,
  config,
  outputs,
  ...
}:
let
  topology = outputs.topology.${pkgs.stdenv.hostPlatform.system}.config;
  inherit (topology.lib.helpers) getAddress getLokiPort;
  lil-nas = (getAddress "lil-nas" "enp5s0");
  lokiPort = (getLokiPort "lil-nas");
in
{
  services.alloy.enable = true;

  environment.etc."alloy/config.alloy".text = ''
    discovery.relabel "journal" {
    	targets = []

    	rule {
    		source_labels = ["__journal__systemd_unit"]
    		target_label  = "unit"
    	}
    }

    loki.source.journal "journal" {
    	max_age       = "12h0m0s"
    	relabel_rules = discovery.relabel.journal.rules
    	forward_to    = [loki.write.default.receiver]
    	labels        = {
    		host = "${config.networking.hostName}",
    		job  = "systemd-journal",
    	}
    }

    loki.write "default" {
    	endpoint {
    		url = "http://${lil-nas}:${lokiPort}/loki/api/v1/push"
    	}
    	external_labels = {}
    }
  '';
}
