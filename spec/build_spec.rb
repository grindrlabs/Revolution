#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rspec'
require 'yaml'
require 'revolution/build'

describe 'Build' do
  # TODO: fix log_dir path so it works for both Vagrant and Travis
  context 'passing in grindr-base with recipes/ directory mounted' do
    describe '.log' do
      it 'makes sure the recipes/grindr-base/log/ directory exists' do
        pkg_name = 'grindr-base'
        Build.log(pkg_name)
        log_dir = "recipes/#{pkg_name}/log"
        expect(Dir.exist?(log_dir)).to be true
      end
    end

    describe '.build_package' do

      before(:all) do
        @name    = 'grindr-base'
        @pkg_dir = "recipes/#{@name}/pkg"
        @return  = Build.build_package(@name)
      end
      it 'creates directory recipes/grindr-base/pkg' do
        expect(Dir.exist?(@pkg_dir)).to be true
      end

      it 'returns successfully' do
        expect(@return).to be 'success'
      end

      it 'creates an .rpm - TODO' do
        # TODO
      end

      it 'creates an .rpm with the correct version number - TODO' do
        # TODO
        # recipe = YAML.load(File.read("recipes/#{@name}/recipe.rb"))
      end
    end


    describe '.clean' do
      it 'successfully cleans grindr-base' do
        pkg = 'grindr-base'
        expect(Build.clean(pkg)).to be 'success'
      end

      it 'deletes directory tmp-dest/' do
        pkg      = 'grindr-base'
        tmp_path = 'recipes/' + pkg + '/tmp-dest'
        expect(Dir.exist?(tmp_path)).to be false
      end
    end
  end
end
