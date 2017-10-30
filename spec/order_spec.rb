#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rspec'
require 'revolution/order'
require 'revolution/recipes'

describe 'Order' do
  describe 'build_order' do
    context 'when passed a valid list of projects' do
      it 'returns a list of @targets to build ordered by dependency' do
        projects = Recipes.load_recipes('examples/')
        expect(Order.resolve_dependencies(projects)).to be_an Array
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
