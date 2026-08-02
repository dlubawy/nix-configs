{ prev, ... }:
{
  pname = "age-plugin-yubikey";
  version = "0.5.0";
  src = prev.fetchFromGitHub {
    owner = "dlubawy";
    repo = "age-plugin-yubikey";
    rev = "feat/tagpq";
    hash = "sha256-yplYJ2Wu5ggTpavOaUuXgvV6cMkzEKdlWwbXTJhHPmM=";
  };
  cargoHash = "";
  cargoDeps = prev.rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "age-core-0.11.0" = "sha256-8ofjDAXt5+LY+okaclSbZuS/nncqFl3pEYgVvN3syCY=";
    };
  };
  fixupPhase = ''
    runHook preFixup
    cp $out/bin/age-plugin-yubikey $out/bin/age-plugin-tagpq
    runHook postFixup
  '';
}
