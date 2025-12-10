{ prev, ... }:
{
  # NOTE: null_pmksa_cache.patch is required because PMKSA is broken with dynamic VLAN
  # PMKSA is still needed for 5G and Apple devices to work
  # Authentication will not work in those instances with disable_pmksa_caching=1
  # Having an empty cache list on each get call has been the only fix I have found so far
  # patches = prev.hostapd.patches ++ [
  #   ./pmksa_vlan_fixes.patch
  # ];
  src = prev.fetchgit {
    url = "https://git.w1.fi/hostap.git";
    rev = "5d0f442c0ce67b7afacc10a512c09fedc2c75192";
    hash = "sha256-5HG/0WZPR5377Mfh2ao9cvemWsyhNuJDxQrk1MibCls=";
  };
}
