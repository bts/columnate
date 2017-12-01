{ mkDerivation, attoparsec, base, containers, Diff, mtl, nix-derivation
, optparse-generic, stdenv, system-filepath, tasty, text, unix, vector
}:
mkDerivation {
  pname = "columnate";
  version = "0.1.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  libraryHaskellDepends = [
    base optparse-generic text vector
  ];
  executableHaskellDepends = [
    base
  ];
  testToolDepends = [ ];
  testHaskellDepends = [
    base tasty text
  ];
  homepage = "https://github.com/bts/columnate";
  description = "Columnate data sets while preserving color codes";
  license = stdenv.lib.licenses.bsd3;
}
