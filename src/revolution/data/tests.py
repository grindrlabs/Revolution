#!/usr/bin/env python
# -*- coding: utf-8 -*-

from revolution.data import (
    Git,
    Project,
    TravisCI,
)
from revolution.scan import find_projects

import os
import unittest


class GitTestCase(unittest.TestCase):
    """Test case for Git methods."""

    def test_get_repository_root(self):
        """Test that get_repository_root returns the root directory of the Git repository."""
        self.assertIsNotNone(Git.get_repository_root())
        self.assertTrue(os.path.isdir(os.path.join(Git.get_repository_root(), '.git')))

    def test_get_files_changed(self):
        """Test that get_files_changed returns a list of all files changed."""
        files = Git.get_files_changed(
            '6b3e7bbf6ed17575a0a956b37231d475b31ff549',
            'b797828abb334be67b42d58cc450a6eb4e3112ac',
        )

        self.assertIn('.travis.yml', files)
        self.assertIn('README.md', files)
        self.assertIn('Makefile', files)


class ProjectTestCase(unittest.TestCase):
    """Test case for project instances."""

    def test_name(self):
        """Tests the name property."""
        self.assertEqual('grindr-base', Project('/vagrant/rpms/grindr-base').name)

    def test_load(self):
        """Tests that load finds the packages which will be built by the project."""
        p = list(filter(lambda p: p.name == 'grindr-base', find_projects()))[0]
        self.assertEqual([], p.packages)
        self.assertEqual([], p.dependencies)
        self.assertEqual([], p.build_dependencies)

        p.load()

        self.assertTrue(len(p.packages) > 0)
        self.assertTrue(len(p.dependencies) > 0)
        self.assertTrue('tree' in p.dependencies)
        self.assertTrue(len(p.build_dependencies) == 0)


class TravisCITestCase(unittest.TestCase):
    """Test case for Travis CI"""

    def test_is_pull_request(self):
        """Tests whether is_pull_request correctly determines whether the current build is a pull request."""
        os.environ['TRAVIS_EVENT_TYPE'] = 'pull_request'
        os.environ['TRAVIS_BRANCH'] = 'feature/dangus'

        self.assertTrue(TravisCI.is_pull_request())

        os.environ['TRAVIS_EVENT_TYPE'] = 'push'
        os.environ['TRAVIS_BRANCH'] = 'feature/brangus'

        self.assertTrue(TravisCI.is_pull_request())

        os.environ['TRAVIS_BRANCH'] = 'master'

        self.assertFalse(TravisCI.is_pull_request())

    def test_get_current_branch(self):
        """Tests whether get_current_branch retrieves the branch name from Travis properly."""
        os.environ['TRAVIS_EVENT_TYPE'] = 'pull_request'
        os.environ['TRAVIS_PULL_REQUEST_BRANCH'] = 'feature/badangus'

        self.assertEqual('feature/badangus', TravisCI.get_current_branch())

        os.environ['TRAVIS_EVENT_TYPE'] = 'push'
        os.environ['TRAVIS_BRANCH'] = 'feature/bobangus'

        self.assertEqual('feature/bobangus', TravisCI.get_current_branch())
