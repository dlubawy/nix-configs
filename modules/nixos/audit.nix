{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
in
{
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

        # 10. Remove extraneous audit messages
        "-a exclude,always -F msgtype=SERVICE_START"
        "-a exclude,always -F msgtype=SERVICE_STOP"
        "-a exclude,always -F msgtype=BPF"
      ];
    };
  };
}
