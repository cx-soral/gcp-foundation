.PHONY: all bigbang install-module create-application

all:
	@echo "Specify a command to run"

init:
	pip install PyYAML

bigbang: init
	python main.py bigbang

install-module: init
	@if [ -z "$(module_name)" ]; then \
		echo "Module name not specified. Usage: make install-module module_name=<module_name>"; \
	else \
		python main.py install-module $(module_name); \
	fi

create-app: init
	@if [ -z "$(app_name)" ]; then \
		echo "Application name not specified. Usage: make create-app app_name=<app_name>"; \
	else \
		python main.py create-app $(app_name); \
	fi