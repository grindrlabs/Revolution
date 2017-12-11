# frozen_string_literal: true

require 'spec_helper'
require 'revolution/cli'

RSpec.describe Revolution::CLI do
  context 'using CLI' do
    let(:cli) { Class.new(Revolution::CLI) }
    let(:path) { 'examples/' }
    let(:golang) { 'golang' }
    let(:go_path) { 'examples/' + golang }

    describe '#all' do
      it 'complains when required options are missing' do
        expect(cli.start(%w[all])).to be nil
      end
      it 'does all the things'
    end

    describe '#diff' do
      it 'looks for packages that have changed'
    end

    describe '#order' do
      it 'complains when required options are missing' do
        expect(cli.start(%w[order])).to be nil
      end
      it 'outputs the build order' do
        cmd = %w[order --recipe-root].push(path)
        expect(cli.start(cmd)).to be_an Array
      end
    end

    describe '#build' do
      it 'complains when required options are missing' do
        expect(cli.start(%w[build])).to be nil
      end
      it 'runs the fpm-cook build command'
    end

    describe '#clean' do
      it 'complains when required options are missing' do
        expect(cli.start(%w[clean])).to be nil
      end
      it 'removes package and temp dirs for one package' do
        cmd = %w[clean golang --recipe-root].push(path)
        expect(cli.start(cmd)).not_to be_a Thor::Error
        tmpdirs = ['cache', 'pkg', 'tmp-*']
        tmpdirs.each do |dir|
          expect(Dir.exist?("#{go_path}/#{dir}")).to be false
        end
      end

      it 'removes package and temp dirs for all packages' do
        cmd = %w[clean --all --recipe-root].push(path)
        expect(cli.start(cmd)).not_to be_a Thor::Error
        tmpdirs = %w[cache pkg tmp-*]
        tmpdirs.each do |dir|
          expect(Dir.exist?("examples/*/#{dir}")).to be false
        end
      end
    end

    describe '#sign' do
      it 'signs packages'
    end

    describe '#deploy' do
      it 'deploys to S3'
    end
  end
end
