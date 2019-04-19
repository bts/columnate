# You can build this repository using Nix by running:
#
#     $ nix-build release.nix
#
# You can also open up this repository inside of a Nix shell by running:
#
#     $ nix-shell
#
# ... and then Nix will supply the correct Haskell development environment for
# you
let
  config = {
    packageOverrides = pkgs: {

      haskellPackages = pkgs.haskellPackages.override {
        overrides = haskellPackagesNew: haskellPackagesOld: {
          columnate = haskellPackagesNew.callPackage ./default.nix {
            libffi = pkgs.libffi.overrideDerivation (attrs: {
              configureFlags = [
              "--with-gcc-arch=generic" # no detection of -march= or -mtune=
              "--enable-pax_emutramp"
              "--enable-static"
              ];
            });
          };
        };
      };

    };
  };

  pkgs =
    (import <nixpkgs> { inherit config; }).pkgsMusl;

in
  { columnate = pkgs.haskellPackages.columnate;
  }
