{ pkgs, ... }:
let
  nixos-mkpasswd = pkgs.writeShellApplication {
    name = "nixos-mkpasswd";
    runtimeInputs = with pkgs; [
      mkpasswd
    ];
    text = (builtins.readFile ./nixos-mkpasswd.sh);
  };
  nixos-passwd = pkgs.writeShellApplication {
    name = "nixos-passwd";
    runtimeInputs = with pkgs; [
      e2fsprogs
      gawk
    ];
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
