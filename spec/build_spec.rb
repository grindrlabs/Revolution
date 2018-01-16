# frozen_string_literal: true

require 'rspec'
require 'revolution/build'
require 'revolution/recipes'

RSpec.describe 'Build' do
  context 'using an example package' do
    let(:pkg_path) { 'examples/golang' }
    let(:recipe_root) { 'examples' }
    let(:result) { Build.build_package(pkg_path) }
    let(:rpms) { Dir.glob(pkg_path + '/pkg/*.rpm') }
    let(:recipe) { Recipes::Recipe.new(File.join(pkg_path, '/recipe.rb')) }
    let(:version) { recipe.data['version'] }
    let(:cleanup) { Build.remove_package(pkg_path) }

    describe '.build_package' do
      it 'returns successfully' do
        expect(result).to be 0
      end
      it 'creates an .rpm' do
        expect(rpms).to be_an Array
        expect(rpms.length).to be 1
        expect(rpms[0]).to end_with('.rpm')
      end
      it 'creates an .rpm with the correct version number' do
        expect(rpms[0].include?(version)).to be true
      end
    end

    describe '.install_build_deps' do
      it 'returns successfully'
      it 'installs required dependencies'
    end

    describe '.clean' do
      let(:tmp_dest) { pkg_path + '/tmp-dest' }
      let(:tmp_build) { pkg_path + '/tmp-build' }

      it 'returns successfully' do
        expect(Build.clean(pkg_path)).to be 0
      end

      it 'removes directory tmp-dest/' do
        expect(Dir.exist?(tmp_dest)).to be false
      end

      it 'removes directory tmp-build/' do
        expect(Dir.exist?(tmp_build)).to be false
      end
    end

    describe '.remove_package' do
      let(:pkg_dir) { pkg_path + '/pkg' }
      let(:cache) { pkg_path + '/cache' }

      it 'returns successfully' do
        expect(Build.remove_package(pkg_path)).to be 0
      end

      it 'removes pkg/ subdirectory' do
        expect(Dir.exist?(pkg_dir)).to be false
      end

      it 'removes cache/ subdirectory' do
        expect(Dir.exist?(cache)).to be false
        cleanup
      end
    end
  end
end
