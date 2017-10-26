#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rspec'
require 'revolution/project'

describe 'Project' do
  context 'project with one recipe and no dependencies' do
    before(:all) do
      @proj = Project.new('examples/golang')
    end

    describe '#initialize' do
      it 'returns a Project object' do
        expect(@proj).to be_a Project
      end
      it 'populates @data' do
        expect(@proj.data['name']).not_to be nil
      end
    end
    describe '#chain_recipes' do
      it 'returns nil' do
        expect(@proj.chain_recipes).to be nil
      end

      describe 'Package' do
        context 'package with no dependencies' do
          before(:all) do
            @go = @proj.packages[0]
          end

          describe '#initialize' do
            it 'returns a Package object' do
              expect(@go).to be_a Project::Package
            end
          end
          describe '#depends?' do
            it 'returns false' do
              expect(@go.depends?).to be false
            end
          end
        end
      end

    end
  end

  context 'project with one package that has dependencies' do
    before(:all) do
      @proj = Project.new('examples/package-with-deps')
    end

    describe '#initialize' do
      it 'returns a Project object' do
        expect(@proj).to be_a Project
      end
      it 'populates @data' do
        expect(@proj.data['name']).not_to be nil
      end
    end

    describe '#chain_recipes' do
      it 'returns nil' do
        expect(@proj.chain_recipes).to be nil
      end
      describe 'Package' do
        context 'package with no dependencies' do
          before(:all) do
            @pkg = @proj.packages[0]
          end
          describe '#initialize' do
            it 'returns a Package object' do
              expect(@pkg).to be_a Project::Package
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

    context 'project with multiple recipes' do
      before(:all) do
        @proj = Project.new('examples/project-chain-recipes')
      end

      describe '#initialize' do
        it 'returns a Project object' do
          expect(@proj).to be_a Project
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
end
