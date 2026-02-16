{ pkgs, ... }:
let
  nixos-mkpasswd = pkgs.writeShellApplication {
    name = "nixos-mkpasswd";
    runtimeInputs = builtins.attrValues {
      inherit (pkgs)
        mkpasswd
        ;
    };
    text = (builtins.readFile ./nixos-mkpasswd.sh);
  };
  nixos-passwd = pkgs.writeShellApplication {
    name = "nixos-passwd";
    runtimeInputs = builtins.attrValues {
      inherit (pkgs)
        e2fsprogs
        gawk
        mkpasswd
        ;
      inherit nixos-mkpasswd;
    };
    text = (builtins.readFile ./nixos-passwd.sh);
  };
in
pkgs.symlinkJoin {
  name = "nixos-password";
  paths = [
    nixos-passwd
    nixos-mkpasswd
  ];
}
