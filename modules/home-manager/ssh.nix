{
  lib,
  config,
  ...
}:
let
  username = config.home.username;
  sshKeys =
    lib.concatMap
      (
        file:
        if lib.hasInfix "yubikey" file.target then
          [ "~/${file.target}" ]
        else
          [ "~/${lib.strings.removeSuffix ".pub" file.target}" ]
      )
      (
        lib.attrValues (
          lib.filterAttrs (name: _: (lib.hasPrefix ".ssh" name && lib.hasSuffix ".pub" name)) config.home.file
        )
      );
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "Host bitbucket.org" = {
        User = "git";
        ControlMaster = "no";
        Ciphers = "chacha20-poly1305@openssh.com";
        IdentitiesOnly = true;
        IdentityFile = [ ] ++ sshKeys;
      };
      "Host github.com" = {
        User = "git";
        ControlMaster = "no";
        MACs = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com";
        IdentitiesOnly = true;
        IdentityFile = [ ] ++ sshKeys;
      };
      "Host bpi" = {
        HostName = "bpi";
        Port = 22;
        User = "${username}";
        ControlMaster = "no";
        IdentitiesOnly = true;
        IdentityFile = [ ] ++ sshKeys;
      };
      "Host lil-nas" = {
        HostName = "lil-nas";
        Port = 22;
        User = "${username}";
        ControlMaster = "no";
        IdentitiesOnly = true;
        IdentityFile = [ ] ++ sshKeys;
      };
      "Host *" = {
        AddressFamily = "inet";
        VisualHostKey = "yes";
        PasswordAuthentication = "no";
        ChallengeResponseAuthentication = "no";
        StrictHostKeyChecking = "ask";
        VerifyHostKeyDNS = "yes";
        ForwardX11 = "no";
        ForwardX11Trusted = "no";
        Ciphers = "aes256-gcm@openssh.com";
        MACs = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com";
        KexAlgorithms = "curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256";
        HostKeyAlgorithms = "rsa-sha2-512,rsa-sha2-256,ssh-ed25519";
        # NOTE: PubkeyAuthentication unbound set because of: https://www.osso.nl/blog/2024/gpg-agent-ssh-ed25519-agent-refused/
        PubkeyAuthentication = "unbound";
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 300;
        ServerAliveCountMax = 2;
        HashKnownHosts = true;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    };
  };
}
