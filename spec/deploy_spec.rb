# frozen_string_literal: true

require 'rspec'
require 'revolution/deploy'

RSpec.describe 'Deploy' do
  describe '.initialize' do
    context 'with no arguments' do
      it 'returns nil' do
        expect(initialize).to be nil
      end
    end

    context 'with arguments' do
      it 'returns what was passed' do
        test = 5
        expect(Deploy.initialize(test)).to eq(5)
      end
    end
  end
end
