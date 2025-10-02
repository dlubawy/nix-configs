{ prev, ... }:
{
  pname = "age-plugin-yubikey";
  version = "0.5.0";
  src = prev.fetchFromGitHub {
    owner = "dlubawy";
    repo = "age-plugin-yubikey";
    rev = "rebase/combined_encryption";
    sha256 = "sha256-C1y0/LT9ERYiDGl0NIGDPTaRyD2EeiGqPHJWWKoNNxs=";
  };
  cargoHash = "";
  cargoDeps = prev.rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "age-core-0.10.0" = "sha256-Iw1KPYhUwfAvLGpYAGuSRhynrRJhD3EqOIS4UY6qC6c=";
      "age-plugin-0.5.0" = "sha256-4wweIMpUSYqEZlXgAEjid7Th0put8gnl2wWF8/htuBw=";
      "yubikey-0.8.0" = "sha256-4wweIMpUSYqEZlXgAEjid7Th0put8gnl2wWF8/htuBw=";
    };
  };
}
