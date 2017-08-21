#!/usr/bin/env make -f

setup:
	@# install bare minimum requirements
	if [ -z "$VIRTUAL_ENV" ]; then \
		pip install --user --upgrade -r requirements.txt ;\
	else \
		pip install --upgrade -r requirements.txt ; \
	fi
	@# bootstrap the project
	buildout

clean:
	rm -fr bin develop-eggs eggs parts src/revolution.egg-info .installed.cfg .python-version
