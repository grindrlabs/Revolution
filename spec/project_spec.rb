#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rspec'
require 'revolution/project'

describe 'inspect_recipe' do
  context 'when passed a valid base directory containing recipe directories' do
    it 'returns hash object containing recipe data' do
      path = 'examples/golang'
      expect(Projects.inspect_recipe(path)).to be_a Hash
    end
  end
  context 'when given an invalid package directory' do
    it 'returns nil' do
      path = Dir.pwd
      expect(Projects.inspect_recipe(path)).to be nil
    end
  end
end

describe 'load_projects' do
  context 'when passed a valid directory containing recipes' do
    before(:all) do
      @projects = Projects.load_projects('examples/')
    end
    it 'returns an array' do
      expect(@projects).to be_an Array
    end
    it 'returns an array of one or more Project objects' do
      expect(@projects[0]).to be_a Projects::Project
    end
  end
end

describe 'Projects' do
  context 'project with one recipe' do
    before(:all) do
      @proj = Projects::Project.new('examples/golang')
    end

    describe '#initialize' do
      it 'returns a Project object' do
        expect(@proj).to be_a Projects::Project
      end
      it 'populates @data' do
        expect(@proj.data['name']).not_to be nil
      end
    end
    describe '#chain_recipes' do
      it 'returns nil' do
        expect(@proj.chain_recipes).to be nil
      end
    end
  end

  context 'project with multiple recipes' do
    before(:all) do
      @proj = Projects::Project.new('examples/project-chain-recipes')
    end

    describe '#initialize' do
      it 'returns a Project object' do
        expect(@proj).to be_a Projects::Project
      end
      it 'populates @data' do
        expect(@proj.data['name']).not_to be nil
      end
    end

    describe '#chain_recipes' do
      it 'returns a list of length 1' do
        expect(@proj.chain_recipes.length).to be 1
      end
    end
  end
end

describe 'Package' do
  context 'package with no dependencies' do
    before(:all) do
      @go = Projects::Package.new('examples/golang')
    end

    describe '#initialize' do
      it 'returns a Package object' do
        expect(@go).to be_a Projects::Package
      end
    end
    describe '#depends?' do
      it 'returns false' do
        expect(@go.depends?).to be false
      end
    end
  end

  context 'package with dependencies' do
    before(:all) do
      @pkg = Projects::Package.new('examples/package-with-deps')
    end

    describe '#initialize' do
      it 'returns a Package object' do
        expect(@pkg).to be_a Projects::Package
      end
    end
    describe '#depends?' do
      it 'returns true' do
        expect(@pkg.depends?).to be true
      end
    end
  end
end
