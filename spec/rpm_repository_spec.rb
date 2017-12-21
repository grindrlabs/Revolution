# frozen_string_literal: true

require 'rspec'
require 'revolution/rpm_repository'

RSpec.describe RPMRepository do
  describe RPMRepository::Manager do
    before(:all) do
      @base_path = File.expand_path(Dir.pwd)
      @centos_path = File.join(@base_path, 'repo/centos/7/x86_64')
      FileUtils.mkdir_p(@centos_path)
    end
    let(:recipe_root) { 'examples/' }
    let(:config) { YAML.load_file(File.join(@base_path, 'test_config.yml')) }
    let(:bucket) do
      s3_client = Aws::S3::Client.new(stub_responses: true)
      repo      = Aws::S3::Resource.new(client: s3_client, region: config['region'])
      repo.bucket(config['bucket'])
    end
    subject { RPMRepository::Manager.new(bucket: bucket, pwd: @base_path) }

    describe '.initialize' do
      it 'creates a Manager object' do
        expect(subject).to be_a RPMRepository::Manager
      end
      it 'accepts a repository bucket' do
        expect(subject.bucket).to be_a Aws::S3::Bucket
      end
      it 'creates repo directory' do
        expect(Dir.exist?('repo')).to be true
      end
    end

    describe '.copy_packages' do
      it 'copies built rpms into repo directory' do
        expect { subject.copy_packages(recipe_root) }.not_to raise_error
      end
    end

    describe '.update_metadata' do
      let(:repodata) { File.join(@centos_path, 'repodata') }
      it 'returns successfully' do
        Dir.chdir(@centos_path)
        expect(subject.update_metadata).to be 0
      end
      it 'creates metadata files' do
        expect(repodata.empty?).to be false
      end
      it 'creates repomd.xml file' do
        expect(File.exist?(File.join(repodata, 'repomd.xml'))).to be true
      end
    end

    describe '.cleanup' do
      it 'removes repo directory' do
        expect { subject.cleanup }.not_to raise_error
        expect(Dir.exist?('repo')).to be false
      end
    end
  end
end
