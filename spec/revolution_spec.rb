#!/usr/bin/env ruby
# frozen_string_literal: true

require 'spec_helper'
require 'revolution'
require 'revolution/exceptions'

RSpec.describe Revolution do
  let(:recipes_root) { 'examples/' }
  describe '.sort_recipes' do
    let(:sorted_recipes) { Revolution.sort_recipes(recipes_root) }
    it 'returns an array of PackageTreeNode objects' do
      expect(sorted_recipes).to be_an Array
      sorted_recipes.each do |recipe|
        expect(recipe).to be_an Order::PackageTreeNode
      end
    end
    it 'sorts recipes by dependency'
  end

  describe '.build_one' do
    let(:result) { Revolution.build_one(recipes_root, 'golang') }
    let(:pkg_dir) { File.join(recipes_root, 'golang', 'pkg/') }
    let(:rpm_glob) { Dir.glob('*.rpm') }
    it 'returns successfully' do
      expect { result }.not_to raise_error
    end
    it 'builds a single package' do
      expect(Dir.exist?(File.join(pkg_dir, rpm_glob))).to be true
    end
  end

  describe '.clean_one' do
    let(:result) { Revolution.clean_one(recipes_root, 'golang') }
    let(:tmp_dirs) { %w[pkg/ cache/ tmp-dest/ tmp-build/] }
    let(:recipe_dir) { File.join(recipes_root, 'golang') }
    it 'returns successfully' do
      expect { result }.not_to raise_error
    end
    it 'removes pkg/ cache/ tmp-dest/ tmp-build/ dirs from a package' do
      tmp_dirs.each do |tmp_dir|
        expect(Dir.exist?(File.join(recipe_dir, tmp_dir))).to be false
      end
    end
  end

  describe '.build_all' do
    let(:result) { Revolution.build_all(recipes_root) }
    let(:pkg_dirs) { Dir.glob(File.join(recipes_root, '*/', 'pkg/')) }
    let(:rpm_glob) { Dir.glob('*.rpm') }
    it 'returns successfully' do
      expect { result }.not_to raise_error
    end
    it 'builds a package for each recipe in recipe_root' do
      pkg_dirs.each do |pkg_dir|
        rpm = File.join(pkg_dir, rpm_glob)
        expect(Dir.exist?(rpm)).to be true
      end
    end
  end

  describe '.clean_all' do
    let(:result) { Revolution.clean_all(recipes_root) }
    let(:recipe_dirs) { Dir.glob(File.join(recipes_root, '*/')) }
    let(:tmp_dirs) { %w[pkg/ cache/ tmp-dest/ tmp-build/] }
    it 'returns successfully' do
      expect { result }.not_to raise_error
    end
    it 'removes pkg/ cache/ tmp-dest/ tmp-build/ dirs from all packages' do
      recipe_dirs.each do |recipe_dir|
        tmp_dirs.each do |tmp_dir|
          expect(Dir.exist?(File.join(recipe_dir, tmp_dir))).to be false
        end
      end
    end
  end

  describe '.check_dir?' do
    it 'does not raise an error if directory exists' do
      expect { Revolution.check_dir('examples/') }.not_to raise_error
    end
    it 'raises error if directory does not exist' do
      expect do
        Revolution.check_dir('fake/')
      end.to raise_error(Revolution::Error::InvalidDirectory)
    end
  end

  describe '.check_pkg?' do
    it 'does not raise an error if package directory exists' do
      expect { Revolution.check_pkg('examples/golang') }.not_to raise_error
    end
    it 'raises error if package directory does not exist' do
      expect do
        Revolution.check_pkg('examples/test')
      end.to raise_error(Revolution::Error::InvalidPackageName)
    end
  end
end

RSpec.describe Revolution do
  it 'has a version number' do
    expect(Revolution::VERSION).not_to be nil
  end
end
