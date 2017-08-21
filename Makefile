#!/usr/bin/env make -f

setup:
	pip install --user --upgrade -r requirements.txt
	buildout

clean:
	rm -fr bin develop-eggs eggs parts src/revolution.egg-info .installed.cfg .python-version
