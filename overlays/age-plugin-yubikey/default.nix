{ prev, ... }:
{
  pname = "age-plugin-yubikey";
  version = "0.5.0";
  src = prev.fetchFromGitHub {
    owner = "dlubawy";
    repo = "age-plugin-yubikey";
    rev = "combined_encryption";
    sha256 = "CydTjyTUwQ3PboOaXjCfFygxSGaAjsircwWqdcvkeOA=";
  };
  cargoHash = "";
  cargoDeps = prev.rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "yubikey-0.8.0-pre.0" = "mF4vrDKLILwP3J5TGdI41sDdLdo09V38UsyHnMefCjg=";
    };
  };
}
