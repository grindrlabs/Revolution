# frozen_string_literal: true

require 'aws-sdk-s3'
require 'yaml'
require 'revolution'
require 'revolution/exceptions'

# Expects AWS credentials to be stored in environment variables
# See https://github.com/naftulikay/aws-env for more information
module RPMRepository
  REPO_DIR      = 'repo'
  CENTOS_SUBDIR = File.join(REPO_DIR, '/centos/7/x86_64')

  def self.get_location(config_file)
    config = YAML.load_file(config_file)
    client = Aws::S3::Client.new(region: config['region'])
    repo   = Aws::S3::Resource.new(client: client) if client.head_bucket(bucket: config['bucket'])
    repo.bucket(config['bucket'])
  end

  class Manager
    attr_reader :bucket, :base_path, :repo_dir, :centos_subdir_local

    def initialize(bucket:, pwd: Dir.pwd)
      @bucket              = bucket
      @base_path           = File.expand_path(pwd)
      @repo_dir            = File.expand_path(init_repo_dir)
      @centos_subdir_local = File.expand_path(CENTOS_SUBDIR)
    end

    def init_repo_dir
      Dir.chdir(@base_path)
      Dir.mkdir(REPO_DIR) unless Dir.exist?(REPO_DIR)
      REPO_DIR
    end

    def fetch_repository
      cmd          = "aws s3 sync s3://#{@bucket.name}/ #{@repo_dir}"
      pid          = Process.spawn(cmd)
      _pid, status = Process.wait2(pid)
      status.exitstatus
    end

    def copy_packages(recipe_root)
      pkg_dirs = Dir.glob(File.join(recipe_root, '*/pkg/'))
      pkg_dirs.each do |pkg_dir|
        Dir.chdir(pkg_dir)
        rpms = Dir.glob(File.join(Dir.pwd, '*.rpm'))
        rpms.each do |rpm|
          FileUtils.cp(rpm, @centos_subdir_local)
        end
      end
    end

    # Must be done on a local copy of the entire RPM repository
    def update_metadata
      Dir.chdir(@centos_subdir_local)
      cmd          = 'createrepo .'
      pid          = Process.spawn(cmd)
      _pid, status = Process.wait2(pid)
      status.exitstatus
    end

    # Re-uploading the entire repository after updating the repo metadata
    def upload_repository
      cmd          = "aws s3 sync #{@repo_dir} s3://#{@bucket.name}/ " \
                     '--acl bucket-owner-full-control'
      pid          = Process.spawn(cmd)
      _pid, status = Process.wait2(pid)
      status.exitstatus
    end

    def cleanup
      Dir.chdir(@base_path)
      FileUtils.remove_dir(@repo_dir) if Dir.exist?(@repo_dir)
    end
  end
end
