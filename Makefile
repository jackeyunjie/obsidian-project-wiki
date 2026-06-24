.PHONY: check ingest update

check:
	bash scripts/check.sh docs/project-wiki --json docs/project-wiki/outputs/wiki-health.json

ingest:
	bash scripts/ingest.sh docs/project-wiki

update:
	bash scripts/update.sh docs/project-wiki
