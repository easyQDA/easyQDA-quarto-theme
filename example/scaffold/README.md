# Scaffold: a bilingual site project on this theme

The project layout that grew out of the first big site built on this
theme (a bilingual curriculum website with generated figures), fed
back here as a copyable starting point. It keeps one principle
throughout: **the repository stays text** — whatever can be generated
from code is generated at build time, locally and in CI alike, and is
never committed.

```
mysite/
├── build.sh              # the whole build, single entry point (from here)
├── Makefile              # incremental figure generation   (from here)
├── de/  en/              # one Quarto website project per language,
│                         #   parallel sidebars (gen_langmap checks this)
├── asset/                # the single copy of every resource; build.sh
│   │                     #   mirrors it into each language project
│   ├── font/             # ← theme font/ (woff2 + noto.css)
│   │   └── ttf/          # ← theme print/font (PDF only; the mirror
│   │                     #   excludes it from the published site)
│   ├── offline/mathjax/  # ← theme offline/mathjax
│   ├── generiert/        # written by `make asset`, gitignored
│   └── …                 # hand-maintained graphics: vector, please
├── code/                 # every script of the project
│   ├── gen_langmap.py    # ← theme script/gen_langmap.py, unchanged
│   ├── postprocess.py    # ← theme offline/postprocess.py, unchanged
│   ├── smoketest.py      # ← theme offline/smoketest.py, unchanged
│   ├── make_pdf.py       # ← theme print/make_pdf.py, unchanged
│   └── abbildungen/      # figure scripts; outputs → asset/generiert/
├── data/
│   └── references.bib    # one bibliography; build.sh symlinks it
│                         #   into each language project
├── root/index.html       # language switch at the site root (from here)
└── _extensions/          # `quarto add easyqda/easyQDA-quarto-theme`
```

The four theme scripts are copied **unchanged**: they find their
resources (MathJax, the TTFs) in the theme layout *and* in this
layout, so vendoring needs no patches. Note the copied files' theme
version somewhere (a comment in build.sh serves), so a later theme
update is a conscious re-copy.

What build.sh adds over a plain `quarto render`, in order:

1. **Pin check** — the build refuses to run on an unpinned Quarto;
   upgrades are deliberate events (build once with
   `ALLOW_UNPINNED_QUARTO=1`, smoketest, eyeball a page, move the pin).
2. **`make asset`** — regenerates the scripted figures incrementally
   (only changed scripts re-run; see `code/abbildungen/README.md`).
3. **Pixel warning** — hand-maintained graphics under `asset/` should
   be vector; pixel formats are a last resort and get a warning.
4. **Chunk guard** — the pages carry no executable code chunks, so the
   sources stay plain, generator-neutral markdown. This is a policy of
   this scaffold, not of the theme: a site that wants executable cells
   (the theme supports them) deletes the guard.
5. **Mirror & symlink** — `_extensions/` and `asset/` are mirrored
   into each language project (Quarto resolves resources only inside a
   project directory), `data/references.bib` is symlinked so one file
   stays the one source.
6. **Fresh output** — the output directory is removed before the
   render; Quarto does not clear deleted pages by itself.
7. **Language map, render, offline repairs, one PDF per language,
   language switch** — the theme's standard pipeline.

CI: `../site-publish.yml` is the GitHub Actions template,
`../site-publish-gitlab.yml` the GitLab (CE) Pages counterpart; both
call this build.sh and publish its output.
