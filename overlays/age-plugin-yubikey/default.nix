{ prev, ... }:
{
  pname = "age-plugin-yubikey";
  version = "0.5.0";
  src = prev.fetchFromGitHub {
    owner = "dlubawy";
    repo = "age-plugin-yubikey";
    rev = "combined_encryption";
    sha256 = "sha256-jSbAWNazFaU9rFbKYKn2JF7QcQF1Utla21Y3oV0qU8Y=";
  };
  cargoHash = "";
  cargoDeps = prev.rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "yubikey-0.8.0" = "sha256-lfoydzwC796raU61ieGiTYKtG4xMENQk5OWxQQyAJg8=";
    };
  };
}
