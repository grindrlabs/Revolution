# frozen_string_literal: true

require 'revolution/recipes'
require 'pp'

module Order
  class PackageTreeNode
    attr_accessor :package, :parent, :children, :package_name

    def initialize(package)
      @package  = package
      @parent   = nil
      @children = []
      @rpm_name = @package.rpm_name
    end
  end

  # Functions for creating data structures (arrays and hashmaps)

  # Assembles list of all the targets in all the projects
  def self.targets(projects)
    targets = []
    projects.each do |proj|
      proj.targets.each do |pkg|
        targets.push(pkg)
      end
    end
    targets
  end

  # Creates Hashmap storing targets by name
  def self.targets_map(targets)
    targets_map = {}
    targets.each do |pkg|
      targets_map[pkg.rpm_name] = pkg
    end
    targets_map
  end

  # Set of PackageTreeNodes, each node obj points to a package
  # Parents and children get resolved by build_trees function
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
      nodes_map[node.package.rpm_name] = node
    end
    nodes_map
  end

  # Dependency resolution algorithm functions

  def self.build_trees(nodes)
    nodes_map = nodes_map(nodes)
    nodes.each do |node|
      node.package.dependencies.each do |dep|
        next unless nodes_map.key?(dep)
        node.children.push(nodes_map[dep])
        # Note: doesn't handle multiple parents
        # Parents are only used to get root nodes
        # Children are used to manage dependencies
        nodes_map[dep].parent = node
      end
    end
  end

  # Goes through list of nodes to find root nodes
  def self.find_root_nodes(nodes)
    roots = []
    nodes.each do |node|
      next unless node.parent.nil?
      roots.push(node)
    end
    roots
  end

  # From list of projects, builds dependency tree
  # and returns a list with the final build order
  def self.resolve_build_order(projects)
    targets = targets(projects)
    nodes   = nodes(targets)
    build_trees(nodes)
    roots = find_root_nodes(nodes)

    final = []
    roots.each do |root|
      list = []
      traverse_build_tree(root, list)
      final.concat(list)
    end
    final.uniq
  end

  # Recursively traverse tree to get build order
  # Build leaf nodes first, then build parents
  def self.traverse_build_tree(node, list)
    node.children.each { |child| traverse_build_tree(child, list) } unless node.nil?
    list.push(node) unless list.include?(node) # skip duplicates
  end

  # Pretty Print functions for sanity checks

  def self.pp_nodes_children(nodes)
    puts "\n\nPARENT DEPENDS ON CHILD:"
    nodes.each do |node|
      puts node.package.rpm_name
      node.children.each do |child|
        puts '    ' + child.package.rpm_name
      end
    end
  end

  def self.pp_build_order(stack)
    puts "\n\nBUILD ORDER:"
    stack.each do |thing|
      puts thing.package.rpm_name
      thing.children.each do |child|
        puts "    #{child.package.rpm_name}"
      end
    end
  end

  # Writes graphviz data to stdout
  # Just a visual sanity check, file IO would be overkill
  # Paste data into webgraphviz.com for graphic
  #
  # Prerequisite: Trees must be built--use after build_trees(nodes)
  def self.print_digraph(nodes)
    puts "\n\n"
    puts 'digraph G {'
    nodes.each do |node|
      print_dot_relationships(node)
    end
    puts '}'
  end

  def self.print_dot_relationships(node)
    name = node.package.rpm_name unless node.package.nil?
    # DOT accepts the same node name multiple times
    # Print node name by itself
    puts("\"#{name}\";")
    node.children.each do |child|
      # Print node name with relationship to child node
      puts("\"#{name}\" -> \"#{child.package.rpm_name}\";") unless node.children.empty?
    end
  end
end
