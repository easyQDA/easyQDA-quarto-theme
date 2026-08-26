# easyQDA-quarto-theme

A Quarto website theme with one distinctive property: the built site
keeps working when it is opened from a plain file tree — `file://`, or
the `chrome://` address of help bundled into a Zotero plugin. Search,
math, the table of contents that follows the scroll, the dark-mode
toggle: all of it, with **no request ever leaving the page** (fonts and
MathJax ship with the site).

The look: a centred three-column layout with a frosted-glass header,
self-hosted Noto Sans, quiet sidebars with a soft accent pill on the
current page, and Quarto's native callouts. Light and dark, switchable.
Built for the [zotQDA](https://zotqda.org) documentation sites; generic
enough for any documentation site with the same needs.

## Install

```sh
quarto add easyqda/easyQDA-quarto-theme
```

then select the format in `_quarto.yml`:

```yaml
format:
  zotqda-theme-html: default
```

The format brings `toc`, `code-copy`, the light/dark pair and an
adaptive syntax-highlight pair (github / github-dark) with it.

## Self-hosted Noto Sans (optional)

Copy `fonts/` into the site project and declare it:

```yaml
project:
  resources:
    - fonts/
format:
  zotqda-theme-html:
    css: fonts/noto.css
```

The woff2 subsets keep their `unicode-range`, so a page only loads the
scripts it uses. Without this block the theme falls back to the system
font stack — still without any external request.

## Offline repairs and their proof

Quarto's output assumes http. `offline/postprocess.py` repairs the
three things that die on `file://` — quarto.js is an ES module, the
search fetches its index, MathJax comes from a CDN:

```sh
quarto render mysite
python3 offline/postprocess.py mysite/_site
python3 offline/smoketest.py  mysite/_site   # headless-browser proof
```

Each repair matches exact strings in Quarto's output and **fails
loudly** when a Quarto update changes them, instead of shipping a site
that breaks only for offline readers. The smoketest then loads real
pages in a headless Chromium-family browser over `file://` and checks
scroll tracking, search, math, fonts and the absence of any CDN
reference. `QDA_SMOKE_BROWSER` overrides the browser autodetection.

## The documentation as one PDF

`print/make_pdf.py` renders a language project as a single PDF: the
chapter order is the sidebar order and top-level sidebar sections
become book parts (so the PDF cannot fall behind a page), the engine
is Typst (bundled with Quarto — no TeX toolchain), Noto Sans is
embedded from `print/fonts/`, the table of contents and the citations
are linked, and one bibliography sits at the end. The cover's subtitle
comes from the front matter of the language's `index.qmd`, and a
project's `asset/` directory is copied into the book so its figures
appear in the PDF too.

```sh
python3 print/make_pdf.py mysite/en mysite/_site/docs.pdf "Jane Doe"
```

Give the site a navbar icon pointing at the file
(`icon: file-pdf`, `href: docs.pdf` — Quarto adjusts the relative
path per page) and call the script from the site's build; the zotQDA
sites do both. One quirk is codified in the script: Quarto's Typst
book cover requires an author and fails without one — pass it as the
third argument or set `author:` in `index.qmd`'s front matter.

## Multilingual sites

`script/gen_langmap.py` makes the header's language switcher send
readers to **the translation of the page being read** instead of the
other language's front page. It takes the language project directories
as arguments, walks their sidebars in parallel — they must list the
same pages in the same order, which is checked, failing the build
loudly when a page was added to one language only — and writes the
page map plus the retargeting logic into each project as
`theme/scripts.html` for `include-after-body`. The map carries all
translations per page, so a third language is one more argument and
one more directory.

`examples/scaffold/` is the layout that grew out of the first big
bilingual site on this theme, fed back as a copyable starting point:
one `asset/` tree mirrored into the language projects, all scripts
vendored under `code/` (they find their resources in either layout,
unpatched), figures generated from `code/abbildungen/` by an
incremental `make asset` step so the repository stays text, a chunk
guard keeping the pages generator-neutral, and a language switch at
the site root.

## Pin your Quarto version

Both the styling rules and the offline repairs are written against a
concrete Quarto version (currently **1.10.18**, see the CI workflow).
Pin it in your build, and treat upgrades as deliberate events: render,
run the smoketest, look at one site, then move the pin. This
repository's CI does exactly that with `examples/minimal/`;
`examples/site-publish.yml` (GitHub Actions) and
`examples/site-publish-gitlab.yml` (GitLab Pages, also self-hosted CE)
are templates for a documentation site's own publish workflow.

## Files

- `_extensions/zotqda-theme/` — the format: `_extension.yml`,
  `zotqda.scss` (shared defaults and all rules), `zotqda-light.scss` /
  `zotqda-dark.scss` (palettes only)
- `fonts/` — Noto Sans woff2 subsets + `noto.css` (SIL OFL 1.1)
- `offline/postprocess.py` — the three offline repairs, loud on drift
- `offline/smoketest.py` — the headless-browser proof
- `offline/mathjax/` — vendored MathJax (Apache 2.0)
- `print/` — the one-PDF builder and the Noto Sans TTFs it embeds
- `script/gen_langmap.py` — the language switcher's page-to-page map
- `examples/minimal/` — the site the CI renders and smokes
- `examples/scaffold/` — a copyable project layout for a full
  bilingual site (build script, figure Makefile, root language switch)

## Maintenance notes

The rules layer targets Quarto's HTML classes (`.sidebar-item-text`,
`#toc-title`, `.quarto-color-scheme-toggle`, …). Those are stable in
practice but not a documented contract — the pin plus the smoketest is
the answer, an eyeball on one page after upgrades is still wise. Three
overrides need `!important` or extra specificity because Quarto's own
rules carry weight; each is commented in `zotqda.scss` where it
happens.

## Licence

MIT (see `LICENSE`). Bundled: Noto Sans under the SIL Open Font
License 1.1 (`fonts/OFL.txt`), MathJax under Apache 2.0
(`offline/mathjax/LICENSE`).
