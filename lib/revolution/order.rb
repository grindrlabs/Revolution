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

  # Assemble list of all the @targets in all the projects
  def self.targets(projects)
    targets = []
    projects.each do |proj|
      proj.targets.each do |pkg|
        targets.push(pkg)
      end
    end
    targets
  end

  # Create Hashmap storing @targets by name
  def self.targets_map(targets)
    targets_map = {}
    targets.each do |pkg|
      targets_map[pkg.name] = pkg
    end
    targets_map
  end

  # Set of PackageTreeNodes, each node obj points to a package
  def self.nodes(targets)
    nodes = []
    targets.each do |pkg|
      nodes.push(PackageTreeNode.new(pkg))
    end
    nodes
  end

  # Hashmap storing nodes by package name
  def self.nodes_map(nodes)
    nodes_map = {}
    nodes.each do |node|
      nodes_map[node.package.name] = node
    end
    nodes_map
  end

  def self.pp_nodes_children(nodes)
    puts "\n\nPARENT DEPENDS ON CHILD:"
    nodes.each do |node|
      puts node.package.name
      node.children.each do |child|
        puts '    ' + child.package.name
      end
    end
  end

  def self.pp_build_order(stack)
    puts "\n\nBUILD ORDER:"
    stack.each do |thing|
      puts thing.package.name
      thing.children.each do |child|
        puts "    #{child.package.name}"
      end
    end
  end

  def self.pp_dot_graph(nodes)
    puts "\n\n"
    puts 'digraph G {'
    nodes.each do |node|
      name = node.package.name unless node.package.nil?
      puts("\"#{name.to_s}\";")
      unless node.children.empty?
        node.children.each do |child|
          puts("\"#{name.to_s}\" -> \"#{child.package.name.to_s}\";")
        end
      end
    end
    puts '}'
  end

  def self.resolve_dependencies(projects)
    targets     = targets(projects)
    targets_map = targets_map(targets)
    nodes       = nodes(targets)
    nodes_map   = nodes_map(nodes)

    # Build the packages tree
    # Parent depends on child
    nodes.each do |node|
      node.package.dependencies.each do |dep|
        if nodes_map.key?(dep)
          node.children.push(nodes_map[dep])
          nodes_map[dep].parent = node
        end
      end
    end

    roots = []
    # Goes through list of nodes to find root nodes
    # Nothing depends on root nodes
    nodes.each do |node|
      next unless node.parent.nil?
      roots.push(node)
    end

    final = []
    roots.each do |root|
      list = []
      traverse_build_tree(root, list)
      final.concat(list)
    end
    puts "\n\nfinal length: #{final.length}"
    puts "\n\nBUILD ORDER:"
    final.each do |node|
      puts node.package.name
    end
    final
  end

  # Recursively traverse tree to get build order
  # Build leaf nodes first, then build parents
  def self.traverse_build_tree(node, list)
    node.children.each { |child| traverse_build_tree(child, list) } unless node.nil?
    list.push(node) unless list.include?(node) # skip duplicates
  end
end
