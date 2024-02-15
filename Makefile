.PHONY: all bigbang install-module create-application

all:
	@echo "Specify a command to run"

bigbang:
	python main.py bigbang

install-module:
	@if [ -z "$(module_name)" ]; then \
		echo "Module name not specified. Usage: make install-module module_name=<module_name>"; \
	else \
		python main.py install-module $(module_name); \
	fi

create-app:
	if [ -z "$(app_name)" ]; then \
		echo "Application name not specified. Usage: make create-app app_name=<app_name>"; \
	else \
		python main.py create-app $(app_name); \
	fi