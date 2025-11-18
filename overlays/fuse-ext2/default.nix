{ prev, final, ... }:
let
  isDarwin = prev.stdenv.hostPlatform.isDarwin;
in
{
  src =
    if isDarwin then
      prev.fetchFromGitHub {
        owner = "macos-fuse-t";
        repo = "fuse-ext2";
        rev = "bef8e702749979fd7680a7b33a8e05d2a21da7f1";
        hash = "sha256-RErvNiXWMB5lgqRVbDdNeJ7xQbmn4FVLTM2/Vk/jW6A=";
      }
    else
      prev.fuse-ext2.src;
  nativeBuildInputs =
    prev.fuse-ext2.nativeBuildInputs
    ++ (prev.lib.optionals isDarwin [
      prev.makeWrapper
    ]);
  buildInputs = [
    prev.e2fsprogs
  ]
  ++ (prev.lib.optionals isDarwin [ final.fuse-t ])
  ++ (prev.lib.optionals (!isDarwin) [ final.fuse ]);
  postInstall =
    if isDarwin then
      ''
        wrapProgram $out/bin/fuse-ext2 --prefix DYLD_LIBRARY_PATH : "${final.fuse-t}/lib"
        wrapProgram $out/bin/fuse-ext2.probe --prefix DYLD_LIBRARY_PATH : "${final.fuse-t}/lib"
      ''
    else
      prev.fuse-ext2.postInstall;
}
