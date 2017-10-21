#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rspec'
require 'yaml'
require 'revolution/build'

describe 'Build' do
  context 'passing in golang example package' do
    describe '.build_package' do
      before(:all) do
        @pkg_path = 'examples/golang'
        @pkg_dir  = "#{@pkg_path}/pkg"
        @return   = Build.build_package(@pkg_path)
      end

      it 'creates directory examples/golang/pkg' do
        expect(Dir.exist?(@pkg_dir)).to be true
      end

      it 'returns successfully' do
        expect(@return).to be 'success'
      end

      it '# TODO: creates an .rpm' do
        # TODO
      end

      it '# TODO: creates an .rpm with the correct version number' do
        # TODO
        # recipe = YAML.load(File.read("recipes/#{@name}/recipe.rb"))
      end
    end

    describe '.clean' do
      before(:all) do
        @pkg_path = 'examples/golang'
      end

      it 'fpm-cook clean command returns successfully' do
        expect(Build.clean(@pkg_path)).to be 'success'
      end

      it 'deletes directory tmp-dest/' do
        tmp_dest = @pkg_path + '/tmp-dest'
        expect(Dir.exist?(tmp_dest)).to be false
      end

      it 'deletes directory tmp-build/' do
        tmp_build = @pkg_path + '/tmp-build'
        expect(Dir.exist?(tmp_build)).to be false
      end
    end
  end
end
