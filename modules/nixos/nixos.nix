{
  pkgs,
  lib,
  config,
  inputs,
  vars,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
    ;
  systemName = config.networking.hostName;
in
{
  imports = [
    ./agenix.nix
    ./disko.nix
    ./hyprland.nix
    ./nix.nix
    ./preservation.nix
    ./tailscale.nix
    ./users.nix
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nix-topology.nixosModules.default
    inputs.nixvim.nixosModules.nixvim
  ];

  options = {
    topology.enable = mkEnableOption "Enable system in topology view";
    boot.secure.enable = mkEnableOption ''
      Enables secure boot using lanzaboote (enable after `sudo sbctl create-keys`)
      Additional docs: https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
    '';
    build-vm = {
      enable = mkEnableOption "Enable build-vm configuration";
      system = mkOption {
        type = types.str;
        description = "Host system for `nixos-rebuild build-vm`";
        default = pkgs.stdenv.buildPlatform.system;
      };
      cores = mkOption {
        type = types.int;
        description = "CPU core count for VM";
        default = 2;
      };
      memorySize = mkOption {
        type = types.int;
        description = "Memory in MiB for VM";
        default = 4096;
      };
    };
  };

  config = {
    assertions = [
      {
        assertion =
          (config.boot.secure.enable)
          -> (config.boot.lanzaboote.enable && (!config.boot.loader.systemd-boot.enable));
        message = "When secure boot is enabled lanzaboote is enabled and systemd-boot is disabled";
      }
    ];

    environment = {
      systemPackages = builtins.attrValues { inherit (pkgs) sbctl; };
      shellAliases = mkIf (builtins.hasAttr "flake" vars) {
        "${systemName}" = "sudo nixos-rebuild switch --flake ${vars.flake}#${systemName}";
      };
    };

    boot = mkMerge [
      {
        initrd.systemd.enable = mkDefault true;
      }
      (mkIf config.boot.secure.enable {
        loader.systemd-boot.enable = mkDefault false;
        lanzaboote = {
          enable = mkDefault true;
          pkiBundle = "/var/lib/sbctl";
        };
      })
    ];

    security = {
      audit = mkIf config.security.auditd.enable {
        enable = mkDefault true;
        rules = [
          # 1. Time and Date Modifications
          "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -S clock_settime -k time-change"
          "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S clock_settime -k time-change"
          "-w /etc/localtime -p wa -k time-change"

          # 2. Identity and Group Modifications
          "-w /etc/group -p wa -k identity"
          "-w /etc/passwd -p wa -k identity"
          "-w /etc/shadow -p wa -k identity"

          # 3. Network Environment Changes
          "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale"
          "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale"
          "-w /etc/issue -p wa -k system-locale"
          "-w /etc/hosts -p wa -k system-locale"

          # 4. Logon and Logout Events
          "-w /var/log/lastlog -p wa -k logins"

          # 5. Permission and Ownership Changes
          (
            if pkgs.stdenv.hostPlatform.isAarch64 then
              "-a always,exit -F arch=aarch64 -S fchmod -S fchmodat -S fchown -S fchownat -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod"
            else
              "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -S chown -S fchown -S fchownat -S lchown -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod"
          )
          (
            if pkgs.stdenv.hostPlatform.isAarch64 then
              "-a always,exit -F arch=arm -S fchmod -S fchmodat -S fchown -S fchownat -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod"
            else
              "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -S chown -S fchown -S fchownat -S lchown -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod"
          )

          # 6. Unauthorized File Access Attempts (Fails)
          (
            if pkgs.stdenv.isAarch64 then
              "-a always,exit -F arch=aarch64 -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access"
            else
              "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access"
          )
          (
            if pkgs.stdenv.isAarch64 then
              "-a always,exit -F arch=arm -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access"
            else
              "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access"
          )
          (
            if pkgs.stdenv.isAarch64 then
              "-a always,exit -F arch=aarch64 -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access"
            else
              "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access"
          )
          (
            if pkgs.stdenv.isAarch64 then
              "-a always,exit -F arch=arm -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access"
            else
              "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access"
          )

          # 7. Sudoers Modifications
          "-w /etc/sudoers -p wa -k scope"

          # 8. Sudo Execution (Log all commands run as root by users)
          "-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k elevated_privs"
          "-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k elevated_privs"

          # 9. Protect Audit Configuration
          "-w /var/log/audit/ -p wa -k audit_log_mod"
          "-w /etc/audit/ -p wa -k audit_config_mod"
        ];
      };
      sudo.execWheelOnly = true;
    };

    programs = {
      nixvim = {
        enable = true;
        nixpkgs.source = inputs.nixpkgs;
      };

      zsh = {
        enable = true;
        enableCompletion = true;
        enableBashCompletion = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
      };

      starship.enable = true;
    };

    networking = {
      networkmanager.enable = lib.mkDefault true;
      nftables.enable = lib.mkDefault true;
      useNetworkd = lib.mkDefault true;
    };

    systemd = {
      network = {
        enable = lib.mkDefault true;
        wait-online.enable = (config.systemd.network.enable && !config.networking.networkmanager.enable);
      };
    };

    system = {
      autoUpgrade = mkIf (builtins.hasAttr "flake" vars) {
        enable = lib.mkDefault true;
        flake = lib.mkDefault "${vars.flake}#${config.networking.hostName}";
        dates = lib.mkDefault "weekly";
        allowReboot = lib.mkDefault true;
        rebootWindow = lib.mkDefault {
          lower = "01:00";
          upper = "05:00";
        };
      };
      etc.overlay.enable = true;
      stateVersion = "${vars.stateVersion}";
    };

    virtualisation = mkIf config.build-vm.enable {
      vmVariantWithDisko = mkIf config.disko.enable {
        virtualisation = {
          host.pkgs = import pkgs.path { system = config.build-vm.system; };
        };
      };

      vmVariant = {
        virtualisation = {
          host.pkgs = import pkgs.path { system = config.build-vm.system; };
          memorySize = config.build-vm.memorySize;
          cores = config.build-vm.cores;
        };
      };
    };
  };
}
