# The figure layer only: regenerates the scripted graphics under
# asset/generiert/ incrementally — after a script change, only the
# changed script runs. asset/generiert/ is gitignored: what comes from
# code is not committed but generated on every build (build.sh calls
# `make asset`, locally and in CI). The site build itself stays
# ./build.sh; make deliberately does not orchestrate Quarto (the
# render is monolithic, fine-grained dependencies gain nothing there).
#
#   make       or  make asset  — regenerate outdated figures
#   make clean                  — drop generiert/ and the stamps:
#                                 the next run rebuilds everything
#
# Since a script chooses its output path under asset/generiert/ freely
# (see code/abbildungen/README.md), make tracks not the outputs but
# one stamp file per script (.stamps/, gitignored). Scripts with a
# leading underscore are skipped; if a script also depends on data,
# add the dependency explicitly (example in the closing comment).

SCRIPTS   := code/abbildungen
STAMPDIR  := $(SCRIPTS)/.stamps
PY_SRC    := $(filter-out $(SCRIPTS)/_%,$(wildcard $(SCRIPTS)/*.py))
R_SRC     := $(filter-out $(SCRIPTS)/_%,$(wildcard $(SCRIPTS)/*.R))
STAMPS    := $(patsubst $(SCRIPTS)/%.py,$(STAMPDIR)/%.py.ok,$(PY_SRC)) \
             $(patsubst $(SCRIPTS)/%.R,$(STAMPDIR)/%.R.ok,$(R_SRC))

.PHONY: asset clean
asset: $(STAMPS)

$(STAMPDIR)/%.py.ok: $(SCRIPTS)/%.py
	@mkdir -p $(STAMPDIR)
	python3 $<
	@touch $@

$(STAMPDIR)/%.R.ok: $(SCRIPTS)/%.R
	@mkdir -p $(STAMPDIR)
	Rscript $<
	@touch $@

clean:
	rm -rf $(STAMPDIR) asset/generiert

# Example of a data dependency: if beispiel.py drew on a CSV, this
# line would make a data change re-run the script as well:
# $(STAMPDIR)/beispiel.py.ok: data/semesterplan.csv
