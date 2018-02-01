# frozen_string_literal: true

require 'revolution/exceptions'

module Utils
  def self.valid_path?(path)
    error_msg = "Invalid path at: #{path}"
    raise Revolution::Error::ExecutionError, error_msg if path.nil?
    true
  end

  def self.valid_dir?(path)
    valid_path?(path)
    error_msg = "Cannot find directory: #{path}"
    raise Revolution::Error::InvalidDirectory, error_msg unless Dir.exist?(path)
    true
  end

  def self.valid_recipe_root?(path)
    valid_path?(path)
    error_msg = "Cannot find recipe root at: #{path}"
    raise Revolution::Error::InvalidDirectory, error_msg unless Dir.exist?(path)
    true
  end

  def self.valid_recipe_dir?(path)
    valid_path?(path)
    error_msg = "Cannot find recipe directory: #{File.basename(path)}"
    raise Revolution::Error::InvalidPackageName, error_msg unless Dir.exist?(path)
    true
  end

  def self.valid_rpm_path?(path)
    valid_path?(path)
    error_msg = "Cannot find specified RPM: #{File.basename(path)}"
    raise Revolution::Error::InvalidRPM, error_msg unless File.exist?(path)
    true
  end

  def self.print_list_with_message(message, list)
    puts message
    list.each { |item| puts ''.ljust(10) + item }
  end
end
