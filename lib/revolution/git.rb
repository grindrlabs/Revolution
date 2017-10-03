#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rugged'

module Git
  def self.initialize
    # points Rugged to existing Git repo in current directory
    Rugged::Repository.new('.')
  end
end

here = Rugged::Repository.new('.')
puts(here.inspect)
puts(here.head.inspect)
