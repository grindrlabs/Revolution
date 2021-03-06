# frozen_string_literal: true

require 'spec_helper'
require 'revolution'
require 'revolution/exceptions'

RSpec.describe Revolution do
  describe '.check_dir?' do
    it 'does not raise an error if directory exists' do
      expect { Revolution.check_dir('examples/') }.not_to raise_error
    end
    it 'raises error if directory does not exist' do
      expect do
        Revolution.check_dir('fake/')
      end.to raise_error(Revolution::Error::InvalidDirectory)
    end
  end

  describe '.check_pkg?' do
    it 'does not raise an error if package directory exists' do
      expect { Revolution.check_pkg('examples/golang') }.not_to raise_error
    end
    it 'raises error if package directory does not exist' do
      expect do
        Revolution.check_pkg('examples/test')
      end.to raise_error(Revolution::Error::InvalidPackageName)
    end
  end
end

RSpec.describe Revolution do
  it 'has a version number' do
    expect(Revolution::VERSION).not_to be nil
  end
end
