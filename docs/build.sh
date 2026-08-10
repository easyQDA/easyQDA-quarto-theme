#!/bin/sh
# Build the documentation: regenerate the language map from the two
# sidebars, render both language projects into ../site/{en,de}, then
# apply the offline repairs so the result works from a plain file tree.
# Verify with:  python3 offline/smoketest.py site/en site/de
set -e
cd "$(dirname "$0")"

# Quarto is pinned; upgrades are deliberate (build with
# ALLOW_UNPINNED_QUARTO=1, run the smoketest, eyeball a page, move the
# pin). Keep equal to the qdaPy/qdaR pins so the sites stay in step.
PINNED="1.9.38"
ACTUAL="$(quarto --version)"
if [ "$ACTUAL" != "$PINNED" ] && [ -z "$ALLOW_UNPINNED_QUARTO" ]; then
  echo "docs/build.sh: quarto is $ACTUAL, pinned is $PINNED" >&2
  exit 1
fi

# gen_langmap needs PyYAML; any python3 with pyyaml serves. The qdaPy
# docs venv has it and is the default where present.
GEN_PY="${GEN_PY:-$HOME/.venvs/qdapy-docs/bin/python}"
command -v "$GEN_PY" >/dev/null 2>&1 || GEN_PY=python3

# This repository IS the theme: the single copy of _extensions/ and
# fonts/ lives at the repository root, and each language project gets a
# disposable mirror before the render, because Quarto only resolves
# extensions and resources inside a project directory.
for lang in en de; do
  rsync -a --delete ../_extensions/ "$lang/_extensions/"
  rsync -a --delete ../fonts/ "$lang/fonts/"
done

"$GEN_PY" gen_langmap.py
quarto render en
quarto render de
python3 ../offline/postprocess.py ../site/en ../site/de

# The same pages once more as one linked PDF per language (Typst, Noto
# Sans embedded), downloadable via the navbar's PDF icon.
"$GEN_PY" ../print/make_pdf.py en ../site/en/zotqda-theme-documentation.pdf
"$GEN_PY" ../print/make_pdf.py de ../site/de/zotqda-theme-Dokumentation.pdf
echo "Done: open ../site/en/index.html"
