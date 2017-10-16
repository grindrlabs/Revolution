#!/usr/bin/env ruby
# frozen_string_literal: true

module TravisCI
  def self.pull_request?
    ENV['TRAVIS_EVENT_TYPE'] == 'pull_request'
  end

  def self.current_branch
    pull_request? ? ENV['TRAVIS_PULL_REQUEST_BRANCH'] : ENV['TRAVIS_BRANCH']
  end

  def self.commit_range
    ENV['TRAVIS_COMMIT_RANGE'].split('...')
  end

  def self.first_commit_in_range
    commit_range[0]
  end

  def self.last_commit_in_range
    commit_range[1]
  end

end
