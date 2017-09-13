#!/usr/bin/env ruby
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Revolution do
  it 'has a version number' do
    expect(Revolution::VERSION).not_to be nil
  end
end
