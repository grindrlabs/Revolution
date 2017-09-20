#!/usr/bin/env ruby
# frozen_string_literal: true

module Build
  def self.build_package(name = nil, location = nil)
    puts '[Inside Build.build_package]'
    puts "Building package: #{name} from #{location}..."
    puts "Package #{name} successfully built!"
  end
end
