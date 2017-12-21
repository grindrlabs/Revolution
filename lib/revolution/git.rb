# frozen_string_literal: true

require 'revolution/travis_ci'
require 'rugged'

module Git
  # Returns a Rugged Repository object pointing to
  # existing Git repo in current directory.
  def self.init_repo
    Rugged::Repository.new(Dir.pwd)
  end

  # Returns a Rugged Diff object for the specific patch.
  # Depends on TravisCI environment variables to determine:
  # - push to master
  # - PR
  def self.diff
    repo = init_repo
    if TravisCI.current_branch == 'master'
      l_blob = repo.lookup(TravisCI.first_commit_in_range)
      r_blob = repo.lookup(TravisCI.last_commit_in_range)
      repo.diff(l_blob, r_blob)
    else
      master = repo.branches['master'].target
      cur    = repo.head.target
      repo.diff(master, cur)
    end
  end
end
