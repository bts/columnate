# columnate

Columnates data sets without stripping color codes, which `column` does on
Linux.

## Building the code

To build the project: `nix-build release.nix`

## Development

To enter a development environment: `nix-shell`
Running a REPL: `cabal repl lib:columnate`
Running ghcid: `ghcid -c "cabal repl lib:columnate --ghc-options=-fno-code"`

Running ghcid for test code: `ghcid -c "cabal repl test-suite:tasty"`. For some
reason I can't get this working with `--ghc-options="-fno-code"` for a faster
(typecheck-only) workflow.
Running a REPL for test code: `cabal repl test-suite:tasty`
