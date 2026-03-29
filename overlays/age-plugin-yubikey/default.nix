{ prev, ... }:
{
  pname = "age-plugin-yubikey";
  version = "0.5.0";
  src = prev.fetchFromGitHub {
    owner = "dlubawy";
    repo = "age-plugin-yubikey";
    rev = "combined_encryption";
    sha256 = "sha256-p9/OovNn3vMvcS+yk98U0g82Np6AH7l/KOMOWMRkchw=";
  };
  cargoHash = "";
  cargoDeps = prev.rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "yubikey-0.8.0" = "sha256-lfoydzwC796raU61ieGiTYKtG4xMENQk5OWxQQyAJg8=";
    };
  };
}
