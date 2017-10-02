#!/usr/bin/env ruby
# frozen_string_literal: true


def build_package(pkg_path)
  pid = Process.spawn("fpm-cook package --no-deps " + pkg_path + '/recipe.rb')

  pid, returncode = Process.wait2(pid)
  puts "+++ Build successful! +++" if returncode == 0
end

def clean(pkg_path)
  pid = Process.spawn("fpm-cook clean " + pkg_path + '/recipe.rb')

  pid, returncode = Process.wait2(pid)
  puts "+++ All clean! +++" if returncode == 0
end

# Temporary function calls for testing:
# Uncomment either build_package() or clean() below
# Run `bundle exec ruby path/to/build.rb` from repo base directory
#
build_package('recipes/grindr-base')
# clean('recipes/grindr-base')
#
# TODO: write entry point calling build_package() and clean()
