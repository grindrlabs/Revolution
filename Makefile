#!/usr/bin/env make -f

setup:
	@# install bare minimum requirements
	pip install --user --upgrade -r requirements.txt
	@# bootstrap the project
	buildout

clean:
	rm -fr bin develop-eggs eggs parts src/revolution.egg-info .installed.cfg .python-version
