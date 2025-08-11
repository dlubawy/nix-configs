{ prev, ... }:
{
  pname = "age-plugin-yubikey";
  version = "0.5.0";
  src = prev.fetchFromGitHub {
    owner = "dlubawy";
    repo = "age-plugin-yubikey";
    rev = "rebase/combined_encryption";
    sha256 = "sha256-UPdl705Y6k7spGhcWAV0u+dsnXistHPBueGfsZodrww=";
  };
  cargoHash = "";
  cargoDeps = prev.rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "age-core-0.10.0" = "sha256-Iw1KPYhUwfAvLGpYAGuSRhynrRJhD3EqOIS4UY6qC6c=";
      "age-plugin-0.5.0" = "sha256-Iw1KPYhUwfAvLGpYAGuSRhynrRJhD3EqOIS4UY6qC6c=";
      "yubikey-0.8.0" = "sha256-7HdETw+1PVFN6BwxfqilpCHvEC6BmtIqOVZf/CzScq8=";
    };
  };
}
