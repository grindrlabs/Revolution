#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'open3'
require 'fpm/cookery/recipe'

module Recipes
  # Takes in path of directory containing all @targets
  # Returns a list of Recipe objects populated with project and package data
  def self.load_recipes(base_path)
    recipes = []

    # Get subdirectories immediately inside of base_path
    recipe_dirs = []
    root        = Dir.pwd
    if Dir.exist?(base_path)
      Dir.chdir(base_path)
      recipe_dirs = Dir.glob('*/')
      Dir.chdir(root)
    end

    # Create Recipe object for each recipe_dir
    recipe_dirs.each do |subpath|
      path = base_path + subpath
      recipes.push(Recipe.new(path)) if File.exist?(path + '/recipe.rb')
    end
    recipes
  end

  # Stores data for a single recipe
  # One recipe has one or more target @targets
  class Recipe
    attr_accessor :package_name, :data, :targets

    def initialize(path)
      @data         = Recipes.inspect(path)
      @package_name = data['name']
      @targets      = []
      if chain_package?
        # TODO
        # for each r in chain_recipes
        #   create a package object with appropriate @data
      else
        @targets.push(Target.new(path))
      end
    end

    def chain_package?
      @data['chain_package']
    end

    def chain_recipes
      @data['chain_recipes'] if chain_package?
    end
  end

  # Stores data for a single target package and its dependencies
  class Target
    attr_accessor :package_name, :data, :dependencies

    def initialize(path)
      @data         = Recipes.inspect(path)
      @package_name = @data['name']
      @dependencies = @data['depends']
    end

    def depends?
      return false if dependencies.empty?
      true
    end
  end

  def self.inspect(path)
    recipe_json = nil
    data        = nil

    cmd = 'fpm-cook inspect ' + path
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      _pid = wait_thr.pid
      stdin.close
      recipe_json = stdout.read
      _err        = stderr.read
      status      = wait_thr.value
      puts 'ERROR: Invalid recipe.rb file!' unless status.exitstatus.zero?
    end

    begin
      data = JSON.parse(recipe_json)
    rescue JSON::ParserError
      # method should only be called when there's a valid recipe file
      # but this is here for testing
      puts 'ERROR: Invalid JSON!'
      return nil
    end
    data
  end
end
