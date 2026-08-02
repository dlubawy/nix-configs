{ prev, ... }:
{
  src = prev.fetchFromGitHub {
    owner = "dlubawy";
    repo = "age";
    rev = "feat/x25519-tag-tagpq-support";
    hash = "sha256-U/u4AXKp9RfVRzFYNOT/oeOikIlyhOSVfxcXK8gNDWs=";
  };
}
