# zotqda-quarto-theme

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
quarto add fre-ms/zotqda-quarto-theme
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
chapter order is the sidebar order (so the PDF cannot fall behind a
page), the engine is Typst (bundled with Quarto — no TeX toolchain),
Noto Sans is embedded from `print/fonts/`, the table of contents and
the citations are linked, and one bibliography sits at the end.

```sh
python3 print/make_pdf.py mysite/en mysite/_site/docs.pdf
```

Give the site a navbar icon pointing at the file
(`icon: file-pdf`, `href: docs.pdf` — Quarto adjusts the relative
path per page) and call the script from the site's build; the zotQDA
sites do both. One quirk is codified in the script: Quarto's Typst
book cover requires an author and fails without one.

## Pin your Quarto version

Both the styling rules and the offline repairs are written against a
concrete Quarto version (currently **1.9.38**, see the CI workflow).
Pin it in your build, and treat upgrades as deliberate events: render,
run the smoketest, look at one site, then move the pin. This
repository's CI does exactly that with `examples/minimal/`;
`examples/site-publish.yml` is a template for a documentation site's
own publish workflow.

## Files

- `_extensions/zotqda-theme/` — the format: `_extension.yml`,
  `zotqda.scss` (shared defaults and all rules), `zotqda-light.scss` /
  `zotqda-dark.scss` (palettes only)
- `fonts/` — Noto Sans woff2 subsets + `noto.css` (SIL OFL 1.1)
- `offline/postprocess.py` — the three offline repairs, loud on drift
- `offline/smoketest.py` — the headless-browser proof
- `offline/mathjax/` — vendored MathJax (Apache 2.0)
- `print/` — the one-PDF builder and the Noto Sans TTFs it embeds
- `examples/minimal/` — the site the CI renders and smokes

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
