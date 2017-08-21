#!/usr/bin/env python
# -*- coding: utf-8 -*-

from setuptools import setup, find_packages

setup(
    name = "revolution",
    version = "0.1.0",
    packages = find_packages('src'),
    package_dir = { '': 'src'},
    author = "Naftuli Kay",
    author_email = "me@naftuli.wtf",
    url = "https://github.com/grindrllc/revolution",
    install_requires = [
        'python-rpm-spec',
        'requests',
        'setuptools',
    ],
    dependency_links = [],
    entry_points = {
        'console_scripts': [
            'revolution = revolution:main'
        ]
    }
)
