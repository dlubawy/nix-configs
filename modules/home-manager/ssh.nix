{
  lib,
  config,
  ...
}:
let
  username = config.home.username;
  sshKeys = lib.concatMap (file: [ "~/${file.target}" ]) (
    lib.attrValues (
      lib.filterAttrs (name: _: (lib.hasPrefix ".ssh" name && lib.hasSuffix ".pub" name)) config.home.file
    )
  );
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "bitbucket.org" = {
        user = "git";
        controlMaster = "no";
        extraOptions = {
          Ciphers = "chacha20-poly1305@openssh.com";
        };
        identitiesOnly = true;
        identityFile = [ ] ++ sshKeys;
      };
      "github.com" = {
        user = "git";
        controlMaster = "no";
        extraOptions = {
          "MACs" =
            "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com";
        };
        identitiesOnly = true;
        identityFile = [ ] ++ sshKeys;
      };
      "bpi" = {
        hostname = "bpi";
        port = 22;
        user = "${username}";
        controlMaster = "no";
        identitiesOnly = true;
        identityFile = [ ] ++ sshKeys;
      };
      "lil-nas" = {
        hostname = "lil-nas";
        port = 22;
        user = "${username}";
        controlMaster = "no";
        identitiesOnly = true;
        identityFile = [ ] ++ sshKeys;
      };
      "*" = {
        addressFamily = "inet";
        extraOptions = {
          "VisualHostKey" = "yes";
          "PasswordAuthentication" = "no";
          "ChallengeResponseAuthentication" = "no";
          "StrictHostKeyChecking" = "ask";
          "VerifyHostKeyDNS" = "yes";
          "ForwardX11" = "no";
          "ForwardX11Trusted" = "no";
          "Ciphers" = "aes256-gcm@openssh.com";
          "MACs" = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com";
          "KexAlgorithms" = "curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256";
          "HostKeyAlgorithms" = "rsa-sha2-512,rsa-sha2-256,ssh-ed25519";
          # NOTE: PubkeyAuthentication unbound set because of: https://www.osso.nl/blog/2024/gpg-agent-ssh-ed25519-agent-refused/
          "PubkeyAuthentication" = "unbound";
        };
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 300;
        serverAliveCountMax = 2;
        hashKnownHosts = true;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
    };
  };
}
