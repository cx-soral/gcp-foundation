.PHONY: all bigbang birth apply init-module create-application

all:
	@echo "Specify a command to run"

init:
	python3 -m venv .venv; \
	sleep 5; \
	. .venv/bin/activate; \
	pip install PyYAML keyring; \
    pip install keyrings.google-artifactregistry-auth; \
    pip install gcp-framework --index-url=https://europe-west1-python.pkg.dev/soral-app-prd/pypi/simple/

bigbang: init
	@if [ -z "$(realm_project)" ]; then \
		echo "Realm project not specified. Usage: make bigbang realm_project=<realm_project>"; \
	else \
		python main.py bigbang -p $(realm_project); \
	fi

birth: init
	@if [ -z "$(foundation_name)" ]; then \
		echo "Foundation name not specified. Usage: make birth foundation_name=<foundation_name>"; \
	else \
	    . .venv/bin/activate; \
		python main.py birth -n $(foundation_name); \
	fi

apply: init
	@. .venv/bin/activate; \
	python main.py prepare

init-module: init
	@if [ -z "$(module_class)" ] || [ -z "$(package)" ]; then \
		echo "Module name not specified. Usage: make init-module module_class=<module_class> package=<package>"; \
	else \
		python main.py init-module -m $(module_class) -p $(package); \
	fi

create-app: init
	@if [ -z "$(app_name)" ]; then \
		echo "Application name not specified. Usage: make create-app app_name=<app_name>"; \
	else \
		python main.py create-app $(app_name); \
	fi