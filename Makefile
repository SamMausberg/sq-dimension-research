.PHONY: install paper check check-caps sources release format lint test lean manifest
PYTHON ?= python
CHECK_OUTPUT ?= work/checks
CAPS_OUTPUT ?= work/checks-with-caps
PAPER_OUTPUT ?= work/paper
RELEASE_OUTPUT ?= dist
install:
	$(PYTHON) -m pip install -r requirements-dev.txt
paper:
	$(PYTHON) -X utf8 tools/build_paper.py --bibtex --report $(PAPER_OUTPUT)/build.json
check:
	$(PYTHON) -X utf8 tools/run_checks.py --output $(CHECK_OUTPUT)
check-caps:
	$(PYTHON) -X utf8 tools/run_checks.py --output $(CAPS_OUTPUT) --caps
sources:
	$(PYTHON) -X utf8 tools/check_sources.py --output $(PAPER_OUTPUT)/sources
release:
	$(PYTHON) -X utf8 tools/package_submission.py --output $(RELEASE_OUTPUT)
format:
	$(PYTHON) -m ruff check --fix .
	$(PYTHON) -m ruff format .
lint:
	$(PYTHON) -m ruff check .
	$(PYTHON) -m ruff format --check .
test:
	$(PYTHON) -X utf8 -m unittest discover -s tests -v
lean:
	cd formalization && $(PYTHON) verify.py --output ../work/lean-verification.json
manifest:
	$(PYTHON) -X utf8 tools/make_manifest.py --check
