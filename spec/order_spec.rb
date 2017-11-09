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

  describe 'resolve_dependencies' do
    context 'when passed a directory of recipes' do
      it 'returns a stack in the proper build order' do
        @final = Order.resolve_dependencies(@projects)
        expect(@final).to be_an Array
        expect(@final.length).to equal(@targets.length)
      end
    end
  end

  describe 'traverse_build_tree' do
    context 'when given a single node' do
      it 'returns a stack of length 1' do
        pkg   = Recipes::Target.new('examples/golang')
        head  = Order::PackageTreeNode.new(pkg)
        stack = []
        stack = Order.traverse_build_tree(head, stack)
        expect(stack).to be_an Array
        expect(stack.length).to be 1
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
