{ prev, ... }:
{
  # NOTE: Fixes PMKSA issues with dynamic VLAN and SAE auth
  src = prev.fetchgit {
    url = "https://git.w1.fi/hostap.git";
    rev = "5d0f442c0ce67b7afacc10a512c09fedc2c75192";
    hash = "sha256-5HG/0WZPR5377Mfh2ao9cvemWsyhNuJDxQrk1MibCls=";
  };
}
