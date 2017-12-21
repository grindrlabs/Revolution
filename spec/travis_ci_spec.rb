# frozen_string_literal: true

require 'rspec'
require 'revolution/travis_ci'

RSpec.describe 'TravisCI' do
  describe '.pull_request?' do
    context 'when pushed from base branch' do
      it 'is not a pull request' do
        ENV['TRAVIS_EVENT_TYPE'] = 'push'
        ENV['TRAVIS_BRANCH']     = 'master'
        expect(TravisCI.pull_request?).to be false
      end
    end

    context 'when PR from feature branch' do
      it 'is a pull request' do
        ENV['TRAVIS_EVENT_TYPE'] = 'pull_request'
        ENV['TRAVIS_BRANCH']     = 'feature/test-branch'
        expect(TravisCI.pull_request?).to be true
      end
    end
  end

  describe '.current_branch' do
    context 'during PR build' do
      it 'returns PR branch name' do
        ENV['TRAVIS_EVENT_TYPE']          = 'pull_request'
        ENV['TRAVIS_PULL_REQUEST_BRANCH'] = 'feature/test-branch'
        expect(TravisCI.current_branch).to eq('feature/test-branch')
      end
    end

    context 'during push build' do
      it 'returns current branch name' do
        ENV['TRAVIS_EVENT_TYPE'] = 'push'
        ENV['TRAVIS_BRANCH']     = 'current_branch_name'
        expect(TravisCI.current_branch).to eq('current_branch_name')
      end
    end
  end

  describe '.commit_range' do
    before(:all) do
      ENV['TRAVIS_COMMIT_RANGE'] = '123...456'
    end

    it 'returns an array' do
      expect(TravisCI.commit_range).to be_an Array
    end

    it 'returns an array containing 2 values' do
      expect(TravisCI.commit_range.length).to be 2
    end

    it 'returns an array with the values for the first and last commits' do
      expect(TravisCI.commit_range).to eq(%w[123 456])
    end
  end
end
