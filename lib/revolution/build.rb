#!/usr/bin/env ruby
# frozen_string_literal: true

module Build
  def self.run(pkg_path, command)
    fpm_cook = 'fpm-cook package --no-deps' if command == 'build'
    fpm_cook = 'fpm-cook clean' if command == 'clean'

    pid          = Process.spawn("#{fpm_cook} #{pkg_path}/recipe.rb")
    _pid, status = Process.wait2(pid)
    status
  end

  def self.build_package(pkg_path)
    clean(pkg_path)
    return 'success' if run(pkg_path, 'build').exitstatus.zero?
  end

  def self.clean(pkg_name)
    return 'success' if run(pkg_name, 'clean').exitstatus.zero?
  end
end
