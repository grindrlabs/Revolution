# frozen_string_literal: true

module Revolution
  class Error < StandardError
    ExecutionFailure   = Class.new(self)
    InvalidDirectory   = Class.new(self)
    InvalidPackageName = Class.new(self)
    InvalidRepository  = Class.new(self)
    InvalidRPM         = Class.new(self)
    InvalidSignature   = Class.new(self)
  end
end
