.PHONY: paper check sources release
paper:
	python tools/build_paper.py
check:
	python tools/run_checks.py
sources:
	python tools/check_sources.py
release:
	python tools/package_submission.py
