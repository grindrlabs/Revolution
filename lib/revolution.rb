# frozen_string_literal: true

require 'revolution/version'
require 'revolution/build'
require 'revolution/rpm_repository'
require 'revolution/order'
require 'revolution/recipes'
require 'revolution/exceptions'
require 'revolution/rpm_sign'
require 'thor'

module Revolution
  def self.sort_recipes(root)
    check_dir(root)
    recipes        = Recipes.load_recipes(root)
    sorted_recipes = Order.resolve_build_order(recipes)
    puts 'Recipes will build in the following order:'
    sorted_names = sorted_recipes.map(&:package_name)
    output_pkg_list(sorted_names)
    sorted_recipes
  end

  def self.build_all(root)
    check_dir(root)
    puts 'Building packages in order...'
    sorted_recipes = sort_recipes(root)
    built_packages = sorted_recipes.map do |recipe|
      pkg_name = recipe.package_name
      build_one(root, pkg_name)
      pkg_name
    end
    puts 'Successfully built the following packages:'
    output_pkg_list(built_packages)
  end

  def self.build_one(root, pkg_name)
    package_path = File.join(root, pkg_name)
    check_pkg(package_path)
    puts "Building package: #{pkg_name}"
    Build.remove_package(package_path)
    Build.build_package(package_path)
    Build.clean(package_path)
  end

  def self.clean_all(root)
    check_dir(root)
    puts 'Removing packages...'
    recipes          = Recipes.load_recipes(root)
    cleaned_packages = recipes.map do |recipe|
      pkg_name = recipe.package_name
      clean_one(root, pkg_name)
      pkg_name
    end
    puts 'Successfully removed the following packages:'
    output_pkg_list(cleaned_packages)
  end

  def self.clean_one(root, pkg_name)
    package_path = File.join(root, pkg_name)
    check_pkg(package_path)
    puts "Removing #{pkg_name}..."
    Build.remove_package(package_path)
    puts "Successfully removed package and temp dirs for #{pkg_name}"
  end

  def self.deploy(config_file, root)
    puts 'Starting deployment...'
    bucket  = RPMRepository.get_location(config_file)
    manager = RPMRepository::Manager.new(bucket: bucket)
    manager.fetch_repository
    manager.copy_packages(root)
    manager.update_metadata
    manager.upload_repository
    manager.cleanup
  end

  def self.sign_all(root)
    pkg_dirs = Dir.glob(root + '/*/pkg/')
    pkg_dirs.each do |pkg_dir|
      check_dir(pkg_dir)
    end
    puts 'Signing packages...'
    rpms = Dir.glob(root + '/*/pkg/*.rpm')
    rpms.each do |rpm|
      rpm_path = File.expand_path(rpm)
      check_rpm(rpm_path)
      sign_one(rpm_path)
    end
  end

  def self.sign_one(rpm_path)
    rpm_path = File.expand_path(rpm_path)
    check_rpm(rpm_path)
    puts "Signing #{rpm_path}..."
    RPMSign.addsign(rpm_path)
    raise Error::InvalidSignature unless RPMSign.signed?(rpm_path)
  end

  def self.check_dir(path)
    error_msg = "Cannot find directory: #{path}"
    raise Error::InvalidDirectory, error_msg unless Dir.exist?(path)
  end

  def self.check_pkg(path)
    error_msg = "Cannot find package at filepath: #{path}"
    raise Error::InvalidPackageName, error_msg unless Dir.exist?(path)
  end

  def self.check_rpm(path)
    basename = File.basename(path)
    raise Error::InvalidRPM, "#{basename} not found" unless File.exist?(path)
  end

  def self.output_pkg_list(list)
    list.each { |item| puts ''.ljust(10) + item }
  end
end
