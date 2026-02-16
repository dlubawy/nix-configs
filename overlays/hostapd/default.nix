{ prev, ... }:
{
  # NOTE: Fixes PMKSA issues with dynamic VLAN and SAE auth
  src = prev.fetchgit {
    url = "https://git.w1.fi/hostap.git";
    rev = "c1e8b1c6462b2f1361648e540a6374ed3f8f1902";
    hash = "sha256-unmbm8ZzWtsOot2DnhfhS4i02I/EdzZl/FgiBkyfK0Y=";
  };
}
