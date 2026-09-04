{ prev, ... }:
{
  src = prev.fetchFromGitHub {
    owner = "dlubawy";
    repo = "age";
    rev = "feat/x25519-tag-tagpq-support";
    hash = "sha256-Tc4hrWeKbdlR1dbSM3LaKoqyKYl4ScYq8l7/n2jhl1c=";
  };
}
