# frozen_string_literal: true

require 'revolution/version'
require 'revolution/build'
require 'revolution/rpm_repository'
require 'revolution/order'
require 'revolution/recipes'
require 'revolution/exceptions'
require 'revolution/rpm_sign'
require 'revolution/utils'
require 'thor'

module Revolution
  def self.get_build_order(recipe_root)
    puts 'Getting build order...' if Utils.valid_recipe_root?(recipe_root)
    recipes = Recipes.load_recipes(recipe_root)
    Order.resolve_build_order(recipes)
  end

  def self.print_build_order(recipe_root)
    sorted_recipes = get_build_order(recipe_root)
    message        = 'Recipes will build in the following order:'
    Utils.print_list_with_message(message, sorted_recipes.map(&:rpm_name))
  end

  def self.build_all(recipe_root)
    puts 'Building packages in order...' if Utils.valid_recipe_root?(recipe_root)
    sorted_recipes = get_build_order(recipe_root)
    built_packages = sorted_recipes.map do |recipe|
      puts "recipe dir: #{recipe.recipe_dir}"
      build_one(recipe_root, recipe.recipe_dir)
      recipe.rpm_name
    end
    message = 'Successfully built the following packages:'
    Utils.print_list_with_message(message, built_packages)
  end

  def self.build_one(recipe_root, package_name)
    recipe_dir = File.join(recipe_root, package_name)
    puts "Building package: #{package_name}" if Utils.valid_recipe_dir?(recipe_dir)
    Build.remove_package(recipe_dir)
    Build.build_package(recipe_dir)
    Build.clean(recipe_dir)
  end

  def self.clean_all(recipe_root)
    puts 'Removing packages...' if Utils.valid_recipe_root?(recipe_root)
    recipe_dirs      = Dir.glob(File.join(recipe_root, '*'))
    results          = []
    cleaned_packages = recipe_dirs.map do |recipe_dir|
      package_name = File.basename(recipe_dir)
      results.push(clean_one(recipe_root, package_name))
      package_name
    end
    message = 'Removed the following packages:'
    Utils.print_list_with_message(message, cleaned_packages) unless results.include?(false)
  end

  # TODO: check if files are there so that output makes more sense
  def self.clean_one(recipe_root, package_name)
    recipe_dir = File.join(recipe_root, package_name)
    puts "Removing #{package_name}..." if Utils.valid_recipe_dir?(recipe_dir)
    Build.remove_package(recipe_dir)

    is_clean = true
    tmpdirs  = %w[cache pkg tmp-*]
    tmpdirs.each do |dir|
      is_clean = false if Dir.exist?(File.join(recipe_dir, dir))
      break
    end
    success_msg = "Successfully removed pkg/ and temp dirs for #{package_name}"
    puts success_msg if is_clean
    is_clean
  end

  def self.deploy(config_file, recipe_root)
    puts 'Starting deployment...' if Utils.valid_recipe_root?(recipe_root)
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
    puts 'Signing packages...' if Utils.valid_recipe_root?(recipe_root)
    rpms = Dir.glob(recipe_root + '/*/pkg/*.rpm')
    rpms.each do |rpm|
      rpm_path = File.expand_path(rpm)
      sign_one(rpm_path) if Utils.valid_rpm_path?(rpm_path)
    end
  end

  def self.sign_one(rpm_path)
    rpm_path = File.expand_path(rpm_path)
    puts "Signing #{rpm_path}..." if valid_rpm_path?(rpm_path)
    RPMSign.addsign(rpm_path)
    raise Error::InvalidSignature unless RPMSign.signed?(rpm_path)
  end
end
