#!/usr/bin/env ruby
# frozen_string_literal: true

module Build
  def self.log(pkg_name)
    # TODO: fix log_dir path so it works for both Vagrant and Travis
    log_dir = "recipes/#{pkg_name}/log"
    Dir.mkdir(log_dir) unless Dir.exist?(log_dir)
    log_dir
  end

  def self.run(pkg_name, command)
    # TODO: add logic for routing output to stdout, logfiles, etc
    fpm_cook = 'fpm-cook package --no-deps' if command == 'build'
    fpm_cook = 'fpm-cook clean' if command == 'clean'

    log_dir = log(pkg_name)
    outfile = "#{log_dir}/#{Time.now.strftime('%F_%T')}"
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
