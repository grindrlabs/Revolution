#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'open3'
require 'fpm/cookery/recipe'

def json_inspect(path)
  cmd = 'fpm-cook inspect ' + path
  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
    pid = wait_thr.pid
    stdin.close
    json   = stdout.read
    err    = stderr.read
    status = wait_thr.value
    # puts err unless status.exitstatus.zero?
    begin
      data = JSON.parse(json)
    rescue JSON::ParserError
      # this should never happen
      # should only be called when there's a valid recipe file
      # but it's here for testing
      return nil
    end
    return data
  end
end


# Takes in path of directory containing all packages
# Returns a list of Project objects populated with project and package data
def load_projects(base_path)
  projects = []
  subdirs  = []
  root = Dir.pwd
  # Get subdirectories immediately inside of base_path
  if Dir.exist?(base_path)
    Dir.chdir(base_path)
    subdirs = Dir.glob('*/')
    Dir.chdir(root)
  end

  subdirs.each do |subpath|
    path = base_path + subpath
    projects.push(Project.new(path)) if File.exist?(path + '/recipe.rb')
  end
  projects
end

class Project
  attr_accessor :name, :data, :packages

  def initialize(path)
    @path = path
    @data = json_inspect(path)

    @packages = []
    if chain_package?
      # TODO
      # for each r in chain_recipes
      #   create a package object with appropriate @data
    else
      @packages.push(Package.new(@path))
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
    @data         = json_inspect(path)
    @path         = path
    @name         = @data['name']
    @recipe       = path + '/recipe.rb'
    @dependencies = @data['depends']
  end

  def depends?
    return false if dependencies.empty?
    true
  end
end
