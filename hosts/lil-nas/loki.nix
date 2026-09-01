{ config, ... }:
{
  networking.firewall.interfaces.enp5s0.allowedTCPPorts = [
    config.services.loki.configuration.server.http_listen_port
  ];
  services = {
    loki = {
      enable = true;
      configuration = {
        auth_enabled = false;
        server.http_listen_port = 3002;

        common = {
          ring = {
            instance_addr = "127.0.0.1";
            kvstore = {
              store = "inmemory";
            };
          };
          replication_factor = 1;
          path_prefix = "/tmp/loki";
        };

        ruler = {
          storage = {
            type = "local";
            local = {
              directory = "${config.services.loki.dataDir}/rules";
            };
          };
          rule_path = "/tmp/loki/rules";
          alertmanager_url = "http://127.0.0.1:9093";
          ring = {
            kvstore = {
              store = "inmemory";
            };
          };
          enable_api = true;
        };

        compactor = {
          working_directory = "${config.services.loki.dataDir}/retention";
          compaction_interval = "10m";
          retention_enabled = true;
          retention_delete_delay = "2h";
          retention_delete_worker_count = 150;
          delete_request_store = "filesystem";
        };

        schema_config = {
          configs = [
            {
              from = "2022-06-06";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        storage_config = {
          filesystem = {
            directory = "${config.services.loki.dataDir}/chunks";
          };
          tsdb_shipper = {
            active_index_directory = "${config.services.loki.dataDir}/index";
            cache_location = "${config.services.loki.dataDir}/index_cache";
          };
        };
      };
    };

    alloy.enable = true;
  };

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
    		url = "http://${toString config.services.loki.configuration.common.ring.instance_addr}:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push"
    	}
    	external_labels = {}
    }

  '';
}
