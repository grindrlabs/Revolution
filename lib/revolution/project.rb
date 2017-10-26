#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'open3'
require 'fpm/cookery/recipe'

class Project
  attr_accessor :name, :data, :packages

  def initialize(path)
    @path = path
    cmd   = 'fpm-cook inspect ' + @path

    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      pid = wait_thr.pid
      stdin.close
      json   = stdout.read
      err    = stderr.read
      @data  = JSON.parse(json)
      status = wait_thr.value
      puts err unless status.exitstatus.zero?
    end

    @packages = []
    if chain_package?
      # TODO
      # for each r in chain_recipes
      #   create a package object with appropriate @data
    else
      @packages.push(Package.new(@path, @data))
    end
  end

  def chain_package?
    @data['chain_package']
  end

  def chain_recipes
    @data['chain_recipes'] if chain_package?
  end

  class Package
    attr_accessor :name, :data, :recipe, :dependencies

    def initialize(path, data)
      @data         = data
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
end
