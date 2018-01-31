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
  def self.sort_recipes(recipe_root)
    puts 'Getting build order...' if valid_dir?(recipe_root)
    recipes        = Recipes.load_recipes(recipe_root)
    sorted_recipes = Order.resolve_build_order(recipes)
    puts 'Recipes will build in the following order:'
    sorted_names = sorted_recipes.map(&:package_name)
    print_packages(sorted_names)
    sorted_recipes
  end

  def self.build_all(recipe_root)
    puts 'Building packages in order...' if valid_dir?(recipe_root)
    sorted_recipes = sort_recipes(recipe_root)
    built_packages = sorted_recipes.map do |recipe|
      package_name = recipe.package_name
      build_one(recipe_root, package_name)
      package_name
    end
    puts 'Successfully built the following packages:'
    print_packages(built_packages)
  end

  def self.build_one(recipe_root, package_name)
    recipe_dir = File.join(recipe_root, package_name)
    puts "Building package: #{package_name}" if valid_recipe_dir?(recipe_root)
    Build.remove_package(recipe_dir)
    Build.build_package(recipe_dir)
    Build.clean(recipe_dir)
  end

  def self.clean_all(recipe_root)
    puts 'Removing packages...' if valid_dir?(recipe_root)
    recipes          = Recipes.load_recipes(recipe_root)
    cleaned_packages = recipes.map do |recipe|
      package_name = recipe.package_name
      clean_one(recipe_root, package_name)
      package_name
    end
    puts 'Successfully removed the following packages:'
    print_packages(cleaned_packages)
  end

  def self.clean_one(recipe_root, package_name)
    recipe_dir = File.join(recipe_root, package_name)
    puts "Removing #{package_name}..." if valid_recipe_dir?(recipe_dir)
    Build.remove_package(recipe_dir)
    puts "Successfully removed package and temp dirs for #{package_name}"
  end

  def self.deploy(config_file, recipe_root)
    puts 'Starting deployment...' if valid_dir?(recipe_root)
    bucket  = RPMRepository.get_location(config_file)
    manager = RPMRepository::Manager.new(bucket: bucket)
    manager.fetch_repository
    manager.copy_packages(recipe_root)
    manager.update_metadata
    manager.upload_repository
    manager.cleanup
  end

  def self.sign_all(recipe_root)
    built_package_dirs = Dir.glob(recipe_root + '/*/pkg/')
    built_package_dirs.each do |built_package_dir|
      valid_dir?(built_package_dir)
    end
    puts 'Signing packages...' if valid_dir?(recipe_root)
    rpms = Dir.glob(recipe_root + '/*/pkg/*.rpm')
    rpms.each do |rpm|
      rpm_path = File.expand_path(rpm)
      sign_one(rpm_path) if valid_rpm_path?(rpm_path)
    end
  end

  def self.sign_one(rpm_path)
    rpm_path = File.expand_path(rpm_path)
    puts "Signing #{rpm_path}..." if valid_rpm_path?(rpm_path)
    RPMSign.addsign(rpm_path)
    raise Error::InvalidSignature unless RPMSign.signed?(rpm_path)
  end

  def self.valid_dir?(path)
    error_msg = "Cannot find directory: #{path}"
    raise Error::InvalidDirectory, error_msg unless Dir.exist?(path)
    true
  end

  def self.valid_recipe_dir?(path)
    error_msg = "Cannot find recipe directory: #{path}"
    raise Error::InvalidDirectory, error_msg unless Dir.exist?(path)
    true
  end

  def self.valid_rpm_path?(path)
    basename = File.basename(path)
    raise Error::InvalidRPM, "#{basename} not found" unless File.exist?(path)
    true
  end

  def self.print_packages(list)
    list.each { |item| puts ''.ljust(10) + item }
  end
end
