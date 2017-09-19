#!/usr/bin/env ruby
# frozen_string_literal: true

module Build
  def self.build_package(name = 'test', location = 'Los Angeles, CA')
    puts '[Inside Build.build_package]'
    puts "Building package: #{name} from #{location}..."
    puts "Package #{name} successfully built!"
  end
end
