#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rspec'
require 'revolution/order'
require 'revolution/recipes'

describe 'Order' do
  before(:all) do
    @projects = Recipes.load_recipes('examples/')
    @targets  = Order.targets(@projects)
    @nodes    = Order.nodes(@targets)
  end

  describe 'targets' do
    it 'returns a list of Target objects' do
      expect(@targets).to be_an Array
      expect(@targets[0]).to be_a Recipes::Target
    end
  end

  describe 'targets_map' do
    it 'returns a Hash storing Target objects' do
      map = Order.targets_map(@targets)
      expect(map).to be_a Hash
      map.keys.each do |key|
        expect(map[key]).to be_a Recipes::Target
      end
    end
  end

  describe 'nodes' do
    it 'returns a list of PackageTreeNode objects' do
      expect(@nodes).to be_an Array
      expect(@nodes[0]).to be_an Order::PackageTreeNode
    end
  end

  describe 'nodes_map' do
    it 'returns a Hash storing PackageTreeNode objects' do
      map = Order.nodes_map(@nodes)
      expect(map).to be_a Hash
      map.keys.each do |key|
        expect(map[key]).to be_a Order::PackageTreeNode
      end
    end
  end

  describe 'build_order' do
    context 'when passed a valid list of projects' do
      it 'returns a list of @targets to build ordered by dependency' do
        expect(Order.resolve_dependencies(@projects)).to be_an Array
      end
    end
  end

  describe 'traverse_build_tree' do
    context 'when given valid head and stack' do
      it 'returns an array' do
        pkg   = Recipes::Target.new('examples/golang')
        head  = Order::PackageTreeNode.new(pkg)
        stack = []
        expect(Order.traverse_build_tree(head, stack)).to be_an Array
      end
    end
  end
end

describe 'PackageTreeNode' do
  describe '#initialize' do
    it 'returns a PackageTreeNode object' do
      pkg = Recipes::Target.new('examples/package-with-deps')
      expect(Order::PackageTreeNode.new(pkg)).to be_an Order::PackageTreeNode
    end
  end
end
