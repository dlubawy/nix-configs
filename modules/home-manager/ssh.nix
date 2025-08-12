{
  lib,
  config,
  vars,
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
    extraConfig = ''
      AddressFamily = "inet"
      VisualHostKey = "yes"
      PasswordAuthentication = "no"
      ChallengeResponseAuthentication = "no"
      StrictHostKeyChecking = "ask"
      VerifyHostKeyDNS = "yes"
      ForwardX11 = "no"
      ForwardX11Trusted = "no"
      Ciphers = "aes256-gcm@openssh.com"
      MACs = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com"
      KexAlgorithms = "curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256"
      HostKeyAlgorithms = "rsa-sha2-512,rsa-sha2-256,ssh-ed25519"
    '';
    hashKnownHosts = true;
    forwardAgent = false;
    matchBlocks = {
      "bitbucket.org" = {
        user = "git";
        extraOptions = {
          Ciphers = "chacha20-poly1305@openssh.com";
          ControlMaster = "no";
        };
        identitiesOnly = true;
        identityFile = [ ] ++ sshKeys;
      };
      "github.com" = {
        user = "git";
        extraOptions = {
          ControlMaster = "no";
          "MACs" =
            "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com";
        };
        identitiesOnly = true;
        identityFile = [ ] ++ sshKeys;
      };
      "rpi" = {
        hostname = "192.168.0.34";
        port = 22;
        user = "${username}";
        extraOptions = {
          ControlMaster = "no";
          # FIXME: there is an issue with key length on the host when using a YubiKey with SSH.
          # So we force it to ssh-ed25519, but the root cause should be fixed if possible.
          # Might be related: https://github.com/djmdjm/openssh-portable-wip/pull/9
          HostKeyAlgorithms = "ssh-ed25519";
        };
        identitiesOnly = true;
        identityFile = [ ] ++ sshKeys;
      };
      "bpi" = {
        hostname = "192.168.1.1";
        port = 22;
        user = "${username}";
        extraOptions = {
          ControlMaster = "no";
          # FIXME: there is an issue with key length on the host when using a YubiKey with SSH.
          # So we force it to ssh-ed25519, but the root cause should be fixed if possible.
          # Might be related: https://github.com/djmdjm/openssh-portable-wip/pull/9
          HostKeyAlgorithms = "ssh-ed25519";
        };
        identitiesOnly = true;
        identityFile = [ ] ++ sshKeys;
      };
    };
    serverAliveInterval = 300;
    serverAliveCountMax = 2;
  };
}
