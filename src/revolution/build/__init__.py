#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import os
import re
import shutil
import subprocess
import sys
import tempfile

from revolution.data import Git

logger = logging.getLogger(__name__)


def get_rpm_result_dir(dest='el7'):
    """Generate the target RPM result directory."""
    return os.path.join(Git.get_repository_root(), 'target/{}'.format(dist))


def get_srpm_result_dir(dist='el7'):
    """Generate the source RPM result directory."""
    return os.path.join(Git.get_repository_root(), 'target/{}/sources'.format(dist))


class Builder(object):
    """Build process for a project."""

    def __init__(self, project):
        """Creates a Builder object."""
        self.project = project

    @property
    def srpm_filename(self):
        """Returns the path to the source RPM for this project."""
        return "{name}-{version}-{release}.src.rpm".format(name=self.project.name,
                version=self.project.version, release=self.project.release)

    def build(self):
        """Builds a project."""
        self.fetch_sources()
        self.build_source_rpm()
        self.build_target_rpm()

    def fetch_sources(self):
        """Fetch the sources for a given project."""
        logger.debug("Fetching build sources for {}".format(self.project.name))

        if not os.path.isdir(self.project.sources_dir):
            os.mkdir(self.project.sources_dir)

        # FIXME fetch remote sources

    def build_source_rpm(self):
        """Build a source RPM for a given project."""
        logger.debug("Building source RPM for {}".format(self.project.name))

        with tempfile.TemporaryDirectory() as tmp_dir:
            # 0775 for the mock group
            os.chmod(tmp_dir, 0o0775)

            # build the srpm
            p = subprocess.Popen((
                'mock', '--resultdir', tmp_dir, '--buildsrpm', '--spec', self.project.spec_file,
                    '--sources', self.project.sources_dir
                ), stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=Git.get_repository_root())

            stdout, stderr = p.communicate()

            if not p.returncode == 0:
                sys.stderr.write(stderr.decode('utf-8'))
                raise Exception('Unable to build source RPM.')

            if not os.path.isdir(get_srpm_result_dir()):
                os.makedirs(get_srpm_result_dir())

            shutil.copy2(os.path.join(tmp_dir, self.srpm_filename), get_srpm_result_dir())

    def build_target_rpm(self):
        """Build destination RPMs for a given project."""
        logger.debug("Building target RPM(s) for {}".format(self.project.name))

        with tempfile.TemporaryDirectory() as tmp_dir:
            # 0775 for the mock group
            os.chmod(tmp_dir, 0o0775)

            # build target rpms
            p = subprocess.Popen(('mock', '--rebuild', os.path.join(get_srpm_result_dir(), self.srpm_filename)),
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=Git.get_repository_root())

            stdout, stderr = p.communicate()

            if not p.returncode == 0:
                sys.stderr.write(stderr.decode('utf-8'))
                raise Exception('Unable to build target RPM(s).')

            # find all built RPMs and copy them
            for rpm in filter(lambda f: f.endswith('.rpm'), map(lambda f: os.path.join(tmp_dir, f),
                    os.listdir(tmp_dir))):
                shutil.copy2(rpm, get_rpm_result_dir())
