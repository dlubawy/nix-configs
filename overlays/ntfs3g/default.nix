{ prev, final, ... }:
let
  isDarwin = prev.stdenv.hostPlatform.isDarwin;
in
{
  src =
    if isDarwin then
      prev.fetchFromGitHub {
        owner = "macos-fuse-t";
        repo = "ntfs-3g";
        rev = "f0e5cb0274e30334dd03aefb4fd5a14c239e6756";
        hash = "sha256-35c5H2q1/YsKiyFXC/nd5Ax3fngpcGL0J1TkX2Vk+5M=";
      }
    else
      prev.ntfs3g.src;
  nativeBuildInputs =
    prev.ntfs3g.nativeBuildInputs
    ++ (prev.lib.optionals isDarwin [
      prev.makeWrapper
    ]);
  patches = prev.ntfs3g.patches ++ (prev.lib.optionals isDarwin [ ./header.patch ]);
  buildInputs = [
    prev.gettext
    prev.libuuid
  ]
  ++ prev.lib.optionals (builtins.hasAttr "crypto" prev) [
    prev.gnutls
    prev.libgcrypt
  ]
  ++ prev.lib.optionals isDarwin [
    final.fuse-t
  ];
  postInstall =
    if isDarwin then
      ''
        wrapProgram $out/bin/ntfs-3g --prefix DYLD_LIBRARY_PATH : "${final.fuse-t}/lib"
        wrapProgram $out/bin/ntfs-3g.probe --prefix DYLD_LIBRARY_PATH : "${final.fuse-t}/lib"
      ''
    else
      prev.ntfs3g.postInstall;
}
