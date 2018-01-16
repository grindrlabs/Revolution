# frozen_string_literal: true

require 'rspec'
require 'revolution/rpm_sign'
require 'revolution/exceptions'

RSpec.describe RPMSign do
  let(:rpms) { Dir.glob('examples/*/pkg/*.rpm') }

  describe '.addsign' do
    it 'signs the given rpm package'
    it 'returns successfully'
  end

  describe '.signed?' do
    it 'returns successfully'
    it 'returns false when a package is not signed'
  end
end
