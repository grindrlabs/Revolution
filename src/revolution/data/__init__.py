#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function

from enum import Enum
from git import Repo
from pyrpm.spec import Spec, replace_macros

import git
import json
import os


class Git(object):

    @classmethod
    def get_repository_root(cls):
        """Returns the absolute root directory of the Git repository."""
        path = os.path.abspath(os.getcwd())
        while path != "/":
            if os.path.isdir(os.path.join(path, ".git")):
                return path

            path = os.path.abspath(os.path.join(path, '..'))

    @classmethod
    def get_files_changed(cls, beginning, end='HEAD'):
        """Return a list of the files changed between beginning and end."""
        repo = git.Repo(Git.get_repository_root())
        start = repo.tree(beginning)
        finish = repo.tree(end)

        # find original paths
        diff = start.diff(finish)
        original_paths = list(map(lambda f: f.a_rawpath.decode('utf-8'), diff))
        dest_paths     = list(map(lambda f: f.b_rawpath.decode('utf-8'), diff))

        # return a unique set of paths
        return set(original_paths + dest_paths + repo.untracked_files)


class TravisCI(object):

    @classmethod
    def is_pull_request(cls, base_branch='master'):
        """Returns whether this is a pull-request build."""
        return os.environ.get('TRAVIS_EVENT_TYPE') == 'pull_request' or \
            (os.environ.get('TRAVIS_EVENT_TYPE') == 'push' and os.environ.get('TRAVIS_BRANCH') != base_branch)

    @classmethod
    def get_current_branch(cls):
        """Get the current branch from TravisCI."""
        if os.environ.get('TRAVIS_EVENT_TYPE') == 'pull_request':
            return os.environ.get('TRAVIS_PULL_REQUEST_BRANCH')
        else:
            return os.environ.get('TRAVIS_BRANCH')

    @classmethod
    def get_base(cls, base_branch):
        """Returns the Git ref to start tracking differences from."""
        if TravisCI.get_current_branch() == base_branch:
            return os.environ.get('TRAVIS_COMMIT_RANGE').split('...')[0]
        else:
            return base_branch


class Project(object):
    """A data type representing an individual build project."""

    def __init__(self, path):
        """Creates a Project from a path and a repository root."""
        self.path = path
        self.repository_root = Git.get_repository_root()
        self.spec = None

        self.__name = os.path.basename(self.path)
        self.__version = None
        self.__release = None

        self.children = []
        self.packages = []
        self.dependencies = []
        self.build_dependencies = []

    def __eq__(self, other):
        """Determines equality between instances."""
        if isinstance(other, Project):
            return self.path == other.path
        else:
            return False

    def __hash__(self):
        """Evaluate the hash value of this instance."""
        return hash(self.path)

    def __str__(self):
        """Return a string description of this object."""
        return "Project{}".format(json.dumps({'name': self.name}))

    def __repr__(self):
        """Returns a string representation of this object."""
        return str(self)

    def load(self):
        """Load project from the specfile."""
        self.spec = Spec.from_file(self.spec_file)
        self.__name = replace_macros(self.spec.name, self.spec)
        self.__version = replace_macros(self.spec.version, self.spec)
        self.__release = replace_macros(self.spec.release, self.spec)
        self.packages = list(map(lambda p: replace_macros(p.name, self.spec), self.spec.packages))
        self.dependencies = list(map(lambda d: replace_macros(d, self.spec), self.spec.requires))
        self.build_dependencies = list(map(lambda d: replace_macros(d, self.spec), self.spec.build_requires))

    @property
    def name(self):
        """Get the name of the parent package in the RPM."""
        return self.__name

    @property
    def version(self):
        return self.__version

    @property
    def release(self):
        return self.__release

    @property
    def spec_file(self):
        """Get the RPM spec file path."""
        return os.path.join(self.path, "{}.spec".format(os.path.basename(self.path)))

    @property
    def sources_dir(self):
        """Get the sources directory for the project."""
        return os.path.join(self.path, 'sources')
