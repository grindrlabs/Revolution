#!/usr/bin/env python
# -*- coding: utf-8 -*-

from revolution.data import Git, Project
from revolution.scan import (
    create_plan,
    find_projects,
    Scanner
)

import mock
import os
import unittest


class ScanModuleTestCase(unittest.TestCase):
    """Test case for module level functions of the revolution.scan module."""

    def test_find_projects(self):
        """Tests that find_projects loads all of the projects properly."""
        projects = find_projects()

        self.assertGreater(len(projects), 0)

    @mock.patch.object(Project, 'load')
    def test_create_plan(self, mock_load):
        """Tests that create plan fills in child dependencies."""
        # the dependency graph here looks like this:
        #
        # grindr-role-elasticsearch
        # ├── grindr-java
        # └── grindr-role-base
        #     └── grindr-base
        #         ├── grindr-logging
        #         └── grindr-metrics
        #
        # the expectation is that create_plan will elevate all child dependencies up to be immediate children of
        # grindr-role-elasticsearch

        grindr_base = Project('/vagrant/rpms/grindr-base')
        grindr_base.packages.append('grindr-base')

        grindr_logging = Project('/vagrant/rpms/grindr-logging')
        grindr_logging.packages.append('grindr-logging')

        grindr_metrics = Project('/vagrant/rpms/grindr-metrics')
        grindr_metrics.packages.append('grindr-metrics')

        grindr_role_base = Project('/vagrant/rpms/grindr-role-base')
        grindr_role_base.packages.append('grindr-role-base')

        grindr_java = Project('/vagrant/rpms/grindr-java')
        grindr_java.packages.append('grindr-java')

        grindr_role_elasticsearch = Project('/vagrant/rpms/grindr-role-elasticsearch')
        grindr_role_elasticsearch.packages.append('grindr-role-elasticsearch')

        grindr_base.dependencies.extend(['grindr-logging', 'grindr-metrics'])
        grindr_role_base.dependencies.extend(['grindr-base'])
        grindr_role_elasticsearch.dependencies.extend(['grindr-role-base', 'grindr-java'])

        # invoke
        create_plan([grindr_base, grindr_logging, grindr_metrics, grindr_role_base, grindr_java,
            grindr_role_elasticsearch])

        # test relationships
        self.assertIn(grindr_base, grindr_role_elasticsearch.children)
        self.assertIn(grindr_logging, grindr_role_elasticsearch.children)
        self.assertIn(grindr_metrics, grindr_role_elasticsearch.children)
        self.assertIn(grindr_role_base, grindr_role_elasticsearch.children)
        self.assertIn(grindr_java, grindr_role_elasticsearch.children)


class ScannerTestCase(unittest.TestCase):
    """Test case for the Scanner graph assembler."""

    def test_from_projects(self):
        """Tests that Scanner.from_projects returns a list ordered in the right way."""
        role_base = Project(path='/vagrant/rpms/grindr-role-base')

        java = Project(path='/vagrant/rpms/oracle-jdk')
        base = Project(path='/vagrant/rpms/grindr-base')
        role_elasticsearch = Project(path='/vagrant/rpms/grindr-role-elasticsearch')

        base.children.append(role_base)
        role_base.children.append(role_elasticsearch)
        java.children.append(role_elasticsearch)

        build_order = Scanner.from_projects([
            role_base, java, base, role_elasticsearch
        ])

        self.assertLess(build_order.index(base), build_order.index(role_base))
        self.assertLess(build_order.index(java), build_order.index(role_elasticsearch))
