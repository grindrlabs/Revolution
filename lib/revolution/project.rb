#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'open3'
require 'fpm/cookery/recipe'

def inspect_recipe(path)
  recipe_json = nil
  data = nil

  cmd = 'fpm-cook inspect ' + path
  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
    pid = wait_thr.pid
    stdin.close
    recipe_json = stdout.read
    err         = stderr.read
    status      = wait_thr.value
    puts 'ERROR: Invalid recipe.rb file!' unless status.exitstatus.zero?
  end

  begin
    data = JSON.parse(recipe_json)
  rescue JSON::ParserError
    # json_inspect should only be called when there's a valid recipe file
    # but this is here for testing
    puts 'ERROR: Invalid JSON!'
    return nil
  end
  data
end

# Takes in path of directory containing all packages
# Returns a list of Project objects populated with project and package data
def load_projects(base_path)
  projects    = []

  # Get subdirectories immediately inside of base_path
  recipe_dirs = []
  root        = Dir.pwd
  if Dir.exist?(base_path)
    Dir.chdir(base_path)
    recipe_dirs = Dir.glob('*/')
    Dir.chdir(root)
  end

  # Create Project object for each recipe_dir
  recipe_dirs.each do |subpath|
    path = base_path + subpath
    projects.push(Project.new(path)) if File.exist?(path + '/recipe.rb')
  end
  projects
end

class Project
  attr_accessor :name, :data, :packages

  def initialize(path)
    @data = inspect_recipe(path)

    @packages = []
    if chain_package?
      # TODO
      # for each r in chain_recipes
      #   create a package object with appropriate @data
    else
      @packages.push(Package.new(path))
    end
  end

  def chain_package?
    @data['chain_package']
  end

  def chain_recipes
    @data['chain_recipes'] if chain_package?
  end
end

class Package
  attr_accessor :name, :data, :recipe, :project
  attr_accessor :dependencies

  def initialize(path)
    @data         = inspect_recipe(path)
    @name         = @data['name']
    @recipe       = path + '/recipe.rb'
    @dependencies = @data['depends']
  end

  def depends?
    return false if dependencies.empty?
    true
  end
end
