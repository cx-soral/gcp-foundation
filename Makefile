.PHONY: all bigbang install-module create-application

all:
	@echo "Specify a command to run"

init:
	pip install PyYAML

bigbang: init
	python main.py bigbang

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