# frozen_string_literal: true

require 'spec_helper'
require 'revolution/utils'
require 'revolution/exceptions'

RSpec.describe Utils do
  describe '.valid_dir?' do
    it 'does not raise an error if directory exists' do
      expect { Utils.valid_dir?('examples/') }.not_to raise_error
    end
    it 'raises error if directory does not exist' do
      expect { Utils.valid_dir?('fake/') }.to raise_error(Revolution::Error::InvalidDirectory)
    end
  end

  describe '.valid_recipe_dir?' do
    it 'does not raise an error if package directory exists' do
      expect { Utils.valid_recipe_dir?('examples/golang') }.not_to raise_error
    end
    it 'raises error if package directory does not exist' do
      expect do
        Utils.valid_recipe_dir?('examples/test')
      end.to raise_error(Revolution::Error::InvalidPackageName)
    end
  end
end
