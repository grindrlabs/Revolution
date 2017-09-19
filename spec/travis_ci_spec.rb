#!/usr/bin/env ruby
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

  describe '.base' do
    context 'when pushed from base branch' do
      it 'returns first commit in range' do
        ENV['TRAVIS_EVENT_TYPE']   = 'push'
        ENV['TRAVIS_BRANCH']       = 'master'
        ENV['TRAVIS_COMMIT_RANGE'] = '123...456'
        expect(TravisCI.base('master')).to eq('123')
      end
    end

    context 'when PR from feature branch' do
      it 'returns first commit in range' do
        ENV['TRAVIS_EVENT_TYPE']          = 'pull_request'
        ENV['TRAVIS_PULL_REQUEST_BRANCH'] = 'feature/test-branch'
        ENV['TRAVIS_COMMIT_RANGE']        = '123...456'
        expect(TravisCI.base('master')).not_to eq('feature/test-branch')
      end
    end

    context 'when not from base branch' do
      it 'returns base branch name' do
        ENV['TRAVIS_BRANCH'] = 'current_branch_name'
        expect(TravisCI.base('base_branch_name')).to eq('base_branch_name')
      end
    end
  end

end
