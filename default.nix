{ mkDerivation, attoparsec, base, containers, Diff, hedgehog, mtl
, nix-derivation, optparse-generic, stdenv, system-filepath, tasty
, tasty-hedgehog, text, these, unix, gmp5, glibc
}:
mkDerivation {
  pname = "columnate";
  version = "0.1.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  libraryHaskellDepends = [
    base optparse-generic text these
  ];
  executableHaskellDepends = [
    base
  ];
  testToolDepends = [ ];
  testHaskellDepends = [
    base hedgehog tasty tasty-hedgehog text
  ];
  homepage = "https://github.com/bts/columnate";
  description = "Columnate data sets while preserving color codes";
  license = stdenv.lib.licenses.bsd3;
  enableSharedExecutables = false;
  enableSharedLibraries = false;
  configureFlags = [
    "--ghc-option=-optl=-static"
    "--ghc-option=-optl=-L${gmp5.static}/lib"
    "--ghc-option=-optl=-L${glibc.static}/lib"
  ];
}
