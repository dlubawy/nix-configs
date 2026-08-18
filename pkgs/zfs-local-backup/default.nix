{ pkgs, ... }:
{
  zfs-local-backup = pkgs.writeShellApplication {
    name = "zfs-local-backup";
    runtimeInputs = builtins.attrValues {
      inherit (pkgs)
        gawk
        gnugrep
        zfs
        ;
    };
    text = (builtins.readFile ./zfs-local-backup.sh);
  };
}
