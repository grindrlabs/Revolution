#!/usr/bin/env ruby
# frozen_string_literal: true

module Build
  def self.log
    Dir.mkdir('log') unless Dir.exist?('log')
  end

  def self.run(pkg_name, command)
    fpm_cook = 'fpm-cook package --no-deps' if command == 'build'
    fpm_cook = 'fpm-cook clean' if command == 'clean'

    log
    outfile = "log/#{pkg_name}_#{Time.now.strftime('%F_%T')}.txt"
    output  = File.open(outfile, 'w')

    pid = Process.spawn("#{fpm_cook} recipes/#{pkg_name}/recipe.rb",
                        out: '/dev/null', err: output)

    pid, status = Process.wait2(pid)
    File.delete(output) if status.exitstatus.zero?
    status
  end

  def self.build_package(pkg_name)
    clean(pkg_name)
    return 'success' if run(pkg_name, 'build').exitstatus.zero?
  end

  def self.clean(pkg_name)
    return 'success' if run(pkg_name, 'clean').exitstatus.zero?
  end
end
