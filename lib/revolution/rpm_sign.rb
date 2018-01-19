# frozen_string_literal: true

require 'open3'

module RPMSign
  # Expects passphrase file to exist in environment
  def self.addsign(pkg_file)
    IO.popen(['bin/sign', pkg_file], &:read)
  end

  def self.signed?(pkg_file)
    cmd                      = "rpm -qpi #{pkg_file} | grep -Pi '^signature'"
    stdout, _stderr, _status = Open3.capture3(cmd)
    # Hard-coded for internal use for now
    return false unless stdout.include?('Key ID 8e19d3c724675ec7')
    true
  end
end
