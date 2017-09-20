#!/usr/bin/env ruby
# frozen_string_literal: truerequire 'rspec'

require 'rspec'
require 'revolution/build'

describe 'Build' do
  describe '.build_package' do
    context 'with no arguments' do
      it 'returns nil' do
        expect(Build.build_package).to be nil
      end
    end
  end
end
