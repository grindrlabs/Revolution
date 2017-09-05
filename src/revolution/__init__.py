#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import logging
import os

from revolution.build import Builder
from revolution.data import Git
from revolution.scan import create_plan, find_projects, Scanner


# setup logging
logger = logging.getLogger()
logging.addLevelName(logging.WARNING, 'WARN')
handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s %(levelname)-5s %(name)-5s %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)

logger = logging.getLogger(__name__)


def main():
    parser = argparse.ArgumentParser(prog='revolution', description='The Revolution RPM build tool.')
    subparsers = parser.add_subparsers(dest='command')
    subparsers.required = True

    p_plan = subparsers.add_parser('plan', help='Show the projects and packages that have changed.')

    p_build = subparsers.add_parser('build', help="Build all projects or just the ones which have changed.")
    p_build.add_argument('-a', '--all', action='store_true', help="Build all dependencies regardless of what changed.")
    p_build.add_argument('-b', '--base-branch', help="The base branch to compare against, defaults to 'master'.",
        default='master')
    p_build.add_argument('-q', '--quiet', action="store_true", help="Don't emit build logs from mock.")

    p_deploy = subparsers.add_parser('deploy', help="Deploy built packages to S3.")

    args = parser.parse_args()

    if args.command == 'build':
        build(args.all, args.base_branch, args.quiet)
    elif args.command == 'deploy':
        deploy()
    elif args.command == 'plan':
        plan()


def build(build_all=False, base_branch='master', quiet=False):
    """Starts the build process for revolution."""
    # assemble everything into a nice queue
    logger.info("Starting build process.")

    found_projects = find_projects(os.path.join(Git.get_repository_root(), 'rpms'))
    create_plan(found_projects)
    stack = Scanner.from_projects(found_projects)

    # FIXME find changed files
    # FIXME if build_all is true or the project has changed, build the RPMs
    for project in stack:
        logger.info("Building Project: {}".format(project.name))
        builder = Builder(project)
        builder.build()

def plan():
    """Starts the plan process for revolution."""


def deploy():
    """Starts the deploy process for revolution."""


if __name__ == "__main__":
    main()
