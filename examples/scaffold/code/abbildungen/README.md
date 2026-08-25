# Figures from code

Principle: **whatever can be generated from code is generated from
code** — on every build, locally and in CI. The repository thereby
stays a pure text repository: the scripts (the sources) are committed,
never their outputs. Only graphics that cannot sensibly come from code
live hand-maintained under `asset/` — as vector graphics; pixel
formats are a last resort (photos) and draw a warning from `build.sh`.

Workflow:

1. Put a script here (`*.py` or `*.R`), write its output to
   `asset/generiert/…` — preferably SVG (stays vector in site and
   PDF). `asset/generiert/` is gitignored.
2. Done — `build.sh` calls `make asset` as its first step, locally and
   in CI; every pushed commit regenerates the figures from the current
   code. To generate without a site build: `make asset` (incremental —
   only changed scripts run; stamps in `.stamps/`); `make clean asset`
   rebuilds everything.
3. Files with a leading `_` are skipped. If a script also depends on
   data, add the dependency in the Makefile (example in its closing
   comment).

Python packages the scripts need (matplotlib, …) belong **pinned**
into a `requirements.txt` in this directory: CI installs them before
the build, locally they are installed once. The pinning is the price
of the approach — an unpinned package update could otherwise break
builds or silently change figures. As soon as R scripts with package
needs exist, CI must add r-base and the packages (the CI template has
the hook).

The pages (`*.qmd`) deliberately contain no executable code chunks
(`build.sh` enforces this): generation lives entirely in this script
layer, and the sources stay ordinary markdown that generators other
than Quarto could process too.

`beispiel.py` demonstrates the convention without any dependencies; it
may be deleted as soon as real figures exist.
