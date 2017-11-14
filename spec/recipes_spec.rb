#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rspec'
require 'revolution/recipes'

describe 'Recipes' do
  describe '.inspect' do
    context 'when passed a valid base directory containing recipe directories' do
      it 'returns hash object containing recipe data' do
        path = 'examples/golang'
        expect(Recipes.inspect(path)).to be_a Hash
      end
    end
    context 'when given an invalid package directory' do
      it 'returns nil' do
        path = Dir.pwd
        expect(Recipes.inspect(path)).to be nil
      end
    end
  end

  describe '.load_recipes' do
    context 'when passed a valid directory containing recipes' do
      before(:all) do
        @recipes = Recipes.load_recipes('examples/')
      end
      it 'returns an array' do
        expect(@recipes).to be_an Array
      end
      it 'returns an array of one or more Recipe objects' do
        expect(@recipes[0]).to be_a Recipes::Recipe
      end
    end
  end

  describe '::Recipe' do
    context 'project with one recipe' do
      before(:all) do
        @recipe = Recipes::Recipe.new('examples/golang')
      end

      describe '#initialize' do
        it 'returns a Recipe object' do
          expect(@recipe).to be_a Recipes::Recipe
        end
        it 'populates @data' do
          expect(@recipe.data['name']).not_to be nil
        end
      end

      describe '#chain_recipes' do
        it 'returns nil' do
          expect(@recipe.chain_recipes).to be nil
        end
      end
    end

    context 'project with multiple recipes' do
      before(:all) do
        @recipe = Recipes::Recipe.new('examples/project-chain-recipes')
      end

      describe '#initialize' do
        it 'returns a Recipe object' do
          expect(@recipe).to be_a Recipes::Recipe
        end
        it 'populates @data' do
          expect(@recipe.data['name']).not_to be nil
        end
      end

      describe '#chain_recipes' do
        it 'returns a list of length 1' do
          expect(@recipe.chain_recipes.length).to be 1
        end
      end
    end
  end

  describe '::Target' do
    context 'package with no dependencies' do
      before(:all) do
        @go = Recipes::Target.new('examples/golang')
      end

      describe '#initialize' do
        it 'returns a Target object' do
          expect(@go).to be_a Recipes::Target
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
        @pkg = Recipes::Target.new('examples/package-with-deps')
      end

      describe '#initialize' do
        it 'returns a Target object' do
          expect(@pkg).to be_a Recipes::Target
        end
      end
      describe '#depends?' do
        it 'returns true' do
          expect(@pkg.depends?).to be true
        end
      end
    end
  end
end
