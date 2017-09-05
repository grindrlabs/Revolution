#!/usr/bin/env python
# -*- coding: utf-8 -*-

from revolution.data import Git, Project

import os


def find_projects(basedir=None):
    """Finds all projects in the given directory."""
    basedir = basedir if basedir is not None else os.path.join(Git.get_repository_root(), 'rpms')

    # find all subdirectories and create projects out of em
    return [Project(os.path.join(basedir, p)) for p in os.listdir(basedir) \
        if os.path.isdir(os.path.join(basedir, p))]


def create_plan(projects):
    """Creates a plan out of the given set of projects."""

    def elevate_dependencies(project, root):
        """Elevate and promote child dependencies up to the parent."""
        changed = False
        for child in project.children:
            if not child in root.children:
                root.children.append(child)
                changed = True

            changed = elevate_dependencies(child, root) or changed

        return changed

    # load metadata from disk
    for project in projects:
        project.load()

    # create a hash map for fast lookups of project names
    package_names = { package: project for project in projects for package in project.packages }

    # find all immediate children for each project
    for project in projects:
        for dep_name in project.dependencies + project.build_dependencies:
            if dep_name in package_names.keys():
                dependant = package_names.get(dep_name)
                # add a child to the project itself
                project.children.append(dependant)

    # elevate all descendants up to the root parent project
    changed = True
    while changed:
        for project in projects:
            changed = elevate_dependencies(project, project)

    return projects


class Scanner(object):

    @classmethod
    def should_build(cls, project, files_changed):
        pass

    @classmethod
    def from_projects(cls, projects):
        """Create a stack from a tree of projects."""
        stack = list()
        visited = { i: False for i in projects }

        if len(projects) == 0:
            return stack

        while len(stack) != len(projects):
            for project in projects:
                Scanner.__visit(project, stack, visited)

        return stack

    @classmethod
    def __visit(cls, project, stack, visited):
        """Visit every node and add them to the stack."""
        if visited.get(project):
            return

        # mark as seen
        visited[project] = True

        for child in project.children:
            Scanner.__visit(child, stack, visited)

        # finally insert this in there
        stack.insert(0, project)
