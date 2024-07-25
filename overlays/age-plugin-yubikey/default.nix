{ prev, ... }:
{
  src = prev.fetchFromGitHub {
    owner = "dlubawy";
    repo = "age-plugin-yubikey";
    rev = "combined_encryption";
    sha256 = "Nwqzuv1tJTQcMzN3YPfpJHd2HVEGybX/cAtUabWv8BU=";
  };
  cargoHash = "";
  cargoDeps = prev.rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "yubikey-0.8.0-pre.0" = "mF4vrDKLILwP3J5TGdI41sDdLdo09V38UsyHnMefCjg=";
    };
  };
}
