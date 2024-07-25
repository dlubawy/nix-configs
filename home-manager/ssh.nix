{ vars, ... }:
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
        identityFile = [ "~/.ssh/id_yubikey.pub" ];
      };
      "github.com" = {
        user = "git";
        extraOptions = {
          ControlMaster = "no";
          "MACs" = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com";
        };
        identitiesOnly = true;
        identityFile = [ "~/.ssh/id_yubikey.pub" ];
      };
      "rpi" = {
        hostname = "192.168.0.65";
        port = 22;
        user = "${vars.user}";
        extraOptions = {
          ControlMaster = "no";
        };
        identitiesOnly = true;
        identityFile = [ "~/.ssh/id_yubikey.pub" ];
      };
    };
    serverAliveInterval = 300;
    serverAliveCountMax = 2;
  };

  home.file.".ssh/id_yubikey.pub" = {
    enable = true;
    text = vars.sshKey;
  };
}
