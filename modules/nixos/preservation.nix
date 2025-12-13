{
  lib,
  config,
  inputs,
  ...
}:
let
  inherit (lib) optionals;
  hasPersist =
    (builtins.hasAttr "/persist" config.fileSystems) && config.fileSystems."/persist".enable;
in
{
  imports = [
    inputs.preservation.nixosModules.preservation
  ];

  config =
    let
      etcDir = if config.system.etc.overlay.enable then "/.rw-etc/upper" else "/etc";
    in
    {
      assertions = [
        {
          assertion = config.preservation.enable -> (hasPersist);
          message = "Preservation requires persist mount in fileSystems";
        }
      ];

      preservation = {
        preserveAt."/persist" = {
          directories = [
            "/var/lib/systemd/coredump"
            "/var/lib/systemd/rfkill"
            "/var/lib/systemd/timers"
            "/var/log"
            "/var/db"
          ]
          ++ (optionals config.boot.secure.enable [
            "/var/lib/sbctl"
          ]);

          files = [
            {
              file = "${etcDir}/machine-id";
              inInitrd = true;
            }
            {
              file = "${etcDir}/ssh/ssh_host_rsa_key";
              how = "symlink";
              configureParent = true;
            }
            {
              file = "${etcDir}/ssh/ssh_host_ed25519_key";
              how = "symlink";
              configureParent = true;
            }
            {
              file = "/var/lib/systemd/random-seed";
              how = "symlink";
              inInitrd = true;
              configureParent = true;
            }
          ];
        };
      };
    };
}
