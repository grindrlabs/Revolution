# frozen_string_literal: true

module Revolution
  class Error < StandardError
    ExecutionFailure = Class.new(self)
    InvalidDirectory = Class.new(self)
    InvalidPackageName = Class.new(self)
  end
end
