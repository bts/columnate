{ mkDerivation, attoparsec, base, containers, Diff, mtl
, nix-derivation, optparse-generic, stdenv, system-filepath, text
, unix, vector
}:
mkDerivation {
  pname = "columnate";
  version = "0.1.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base optparse-generic text vector
  ];
  homepage = "https://github.com/bts/columnate";
  description = "Columnate data sets while preserving color codes";
  license = stdenv.lib.licenses.bsd3;
}
