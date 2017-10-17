#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rspec'
require 'revolution/git'

describe 'Git' do

  describe '.init_repo' do
    it 'returns a rugged Repository object' do
      expect(Git.init_repo).to be_a Rugged::Repository
    end
  end

  describe '.diff' do
    context 'on master' do
      it 'returns a diff patch' do
        repo = Git.init_repo
        ENV['TRAVIS_BRANCH'] = 'master'
        r_blob = repo.head.target
        l_blob = r_blob.parents.first.tree_id
        r_blob = r_blob.tree_id
        ENV['TRAVIS_COMMIT_RANGE'] = l_blob + '...' + r_blob
        expect(Git.diff).to be_a Rugged::Diff
      end
    end

    context 'on PR' do
      it 'returns a diff patch' do
        ENV['TRAVIS_BRANCH'] = 'feature/test-branch'
        expect(Git.diff).to be_a Rugged::Diff
      end
    end

  end

end
