#!/usr/bin/env ruby
# frozen_string_literal: true

require 'revolution/recipes'
require 'pp'

module Order
  class PackageTreeNode
    attr_accessor :package, :parent, :children

    def initialize(package)
      @package  = package
      @parent   = nil
      @children = []
    end
  end

  def self.resolve_dependencies(projects)
    # Assemble list of all the @targets in all the projects
    targets = []
    projects.each do |proj|
      proj.targets.each do |pkg|
        targets.push(pkg)
      end
    end

    # Create Hashmap storing @targets by name
    targets_map = {}
    targets.each do |pkg|
      targets_map[pkg.name] = pkg
    end
    # Set of PackageTreeNodes, each node obj points to a package
    nodes = []
    targets.each do |pkg|
      nodes.push(PackageTreeNode.new(pkg))
    end

    # Hashmap storing nodes by package name
    nodes_map = {}
    nodes.each do |node|
      nodes_map[node.package.name] = node
    end

    # Parent depends on child
    nodes.each do |node|
      node.package.dependencies.each do |dep|
        if targets_map.key?(dep)
          node.children.push(nodes_map[dep])
          nodes_map[dep].parent = node
        end
      end
    end

    head = nil
    nodes.each do |node|
      next unless node.parent.nil?
      head = node
      break
    end

    stack = []
    traverse_build_tree(head, stack)
    puts "\n\nBUILD ORDER:"
    pp stack
  end

  # Traverse tree to get build order
  # Build leaf nodes first, then build parents
  def self.traverse_build_tree(node, stack)
    node.children.each { |child| traverse_build_tree(child, stack) } unless node.nil?
    stack.push(node)
  end
end
