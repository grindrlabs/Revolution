#!/usr/bin/env ruby
# frozen_string_literal: true

module TravisCI
  def self.pull_request?
    ENV['TRAVIS_EVENT_TYPE'] == 'pull_request'
  end

  def self.current_branch
    pull_request? ? ENV['TRAVIS_PULL_REQUEST_BRANCH'] : ENV['TRAVIS_BRANCH']
  end

  def self.base(base_branch)
    current_branch == base_branch ? _first_commit_in_range : base_branch
  end

  def self._first_commit_in_range
    ENV['TRAVIS_COMMIT_RANGE'].split('...')[0]
  end
end
