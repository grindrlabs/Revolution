# frozen_string_literal: true

require 'revolution'

module Revolution
  class CLI < Thor
    desc 'all', 'Start Revolution'
    option :recipe_root, required: true
    def all
      raise Error::NotImplementedError, '`all` has not been implemented'
    end

    desc 'diff', 'Check for packages that have changed'
    def diff
      raise Error::NotImplementedError, '`diff` has not been implemented'
    end

    desc 'order', 'Get build order based on dependencies'
    option :recipe_root, required: true
    def order
      puts 'Getting build order...'
      Revolution.sort_recipes(options.recipe_root)
    end

    desc 'build', 'Build packages in order according to dependencies'
    option :recipe_root, required: true
    option :all, type: :boolean
    def build(package_name = nil)
      return Revolution.build_all(options.recipe_root) if options.all
      raise Error::ArgumentError, 'Package name is required' if package_name.nil?
      Revolution.build_one(options.recipe_root, package_name)
    end

    desc 'clean', 'Remove an existing package'
    option :recipe_root, required: true
    option :all, type: :boolean
    def clean(package_name = nil)
      return Revolution.clean_all(options.recipe_root) if options.all
      raise Error::ArgumentError, 'Package name is required' if package_name.nil?
      Revolution.clean_one(options.recipe_root, package_name)
    end

    desc 'sign', 'Sign packages'
    option :recipe_root
    option :all, type: :boolean
    def sign(rpm_path = nil)
      if options.all
        raise Error::ArgumentError, 'Recipe root is required' if options.recipe_root.nil?
        return Revolution.sign_all(options.recipe_root)
      end
      raise Error::ArgumentError, 'RPM path is required' if rpm_path.nil?
      Revolution.sign_one(rpm_path)
    end

    desc 'deploy', 'Deploy built RPMs to S3 bucket'
    option :recipe_root, required: true
    option :config, required: true
    def deploy
      Revolution.deploy(options.config, options.recipe_root)
    end
  end
end
