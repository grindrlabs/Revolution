#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rspec'
require 'yaml'
require 'revolution/build'

describe 'Build' do
  context 'passing in golang example package' do
    describe '.log' do
      it 'makes sure the examples/golang/log directory gets created' do
        pkg_path = 'examples/golang'
        Build.log(pkg_path)
        log_dir = "#{pkg_path}/log"
        expect(Dir.exist?(log_dir)).to be true
      end
    end

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
      it 'fpm-cook clean command returns successfully' do
        pkg_path = 'examples/golang'
        expect(Build.clean(pkg_path)).to be 'success'
      end

      it 'deletes existing .rpms in pkg/' do
        pkg_path = 'examples/golang'
        pkg_dir = pkg_path + '/pkg'
        expect(Dir.empty?(pkg_dir)).to be true
      end
    end
  end
end
