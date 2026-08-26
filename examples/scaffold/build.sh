#!/bin/sh
# Build the site: generate the scripted figures, mirror the shared
# resources into the language projects, regenerate the language map
# from the parallel sidebars, render every language into public/,
# apply the offline repairs, render one linked PDF per language, and
# put the language switch at the site root.
# Verify with:  python3 code/smoketest.py public/de public/en
set -e
cd "$(dirname "$0")"

# The language projects; every loop below and the gen_langmap call use
# this one list. A third language is one more entry here, a sibling
# directory with a parallel sidebar, and a menu entry per _quarto.yml.
LANGS="de en"

# On the PDF cover (Typst's book cover fails without an author).
AUTHOR="Jane Doe"                                        # ← adapt

# Quarto is pinned; upgrades are deliberate events (build with
# ALLOW_UNPINNED_QUARTO=1, run the smoketest, eyeball a page, then
# move the pin). Keep equal to QUARTO_VERSION in the CI config.
PINNED="1.10.18"
ACTUAL="$(quarto --version)"
if [ "$ACTUAL" != "$PINNED" ] && [ -z "$ALLOW_UNPINNED_QUARTO" ]; then
  echo "build.sh: quarto is $ACTUAL, pinned is $PINNED" >&2
  exit 1
fi

# Whatever can be generated from code is generated from code — here,
# on every build, locally and in CI. Results land in asset/generiert/
# (gitignored): the repository stays text.
make asset

# Hand-maintained graphics under asset/ are vector graphics; pixel
# formats are a last resort (photos) — hence a warning, not an abort.
PIX="$(find asset -type f \( -iname '*.png' -o -iname '*.jpg' \
  -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.webp' \) )"
if [ -n "$PIX" ]; then
  echo "build.sh: WARNING — pixel graphics under asset/ (prefer vector):" >&2
  echo "$PIX" >&2
fi

# The pages are deliberately not executable: figures come from the
# `make asset` step above (see code/abbildungen/README.md) — only then
# do the sources stay plain, generator-neutral markdown. A chunk here
# would give that up, so the build aborts. Policy of this scaffold: a
# site that wants executable cells (the theme supports them) deletes
# this block.
if grep -rn --include='*.qmd' '^```{' $LANGS; then
  echo "build.sh: executable code chunks found (see above) —" >&2
  echo "generate figures via \`make asset\` into asset/ instead." >&2
  exit 1
fi

# gen_langmap.py and make_pdf.py need PyYAML; any python3 with pyyaml
# serves (in CI, GEN_PY=python3 with the distro's python3-yaml).
GEN_PY="${GEN_PY:-python3}"

# The one copy of _extensions/ and asset/ lives at the repository
# root, references.bib in data/; each language project gets a
# disposable mirror before the render, because Quarto resolves
# extensions and resources only inside a project directory.
for lang in $LANGS; do
  rsync -a --delete _extensions/ "$lang/_extensions/"
  # fonts/ttf serves only the PDF (make_pdf.py) — do not publish it
  rsync -a --delete --exclude=/fonts/ttf asset/ "$lang/asset/"
  # a symlink instead of a copy: one file stays the one source
  ln -sf ../data/references.bib "$lang/references.bib"
done

# Quarto does not clear removed pages from the output dir; without a
# fresh start deleted pages would linger in the published site.
rm -rf public

"$GEN_PY" code/gen_langmap.py $LANGS
for lang in $LANGS; do
  quarto render "$lang"
done
python3 code/postprocess.py public/de public/en

# The same pages once more as one linked PDF per language (Typst,
# Noto Sans embedded), reachable via the PDF icon in the header.
for lang in $LANGS; do
  "$GEN_PY" code/make_pdf.py "$lang" "public/$lang/mysite-$lang.pdf" "$AUTHOR"
done

# Language switch at the site root: redirects by browser language.
cp root/index.html public/index.html
echo "Done: open public/index.html"
