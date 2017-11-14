#!/usr/bin/env ruby
# frozen_string_literal: true

class Golang < FPM::Cookery::Recipe
  name        'golang'
  description 'Go is an open source programming language'
  homepage    'http://golang.org/'
  maintainer  'ISRE <isre@grindr.com>'

  version     '1.9.1'
  revision    '1'
  sha256      '07d81c6b6b4c2dcf1b5ef7c27aaebd3691cdb40548500941f92b221147c5d9c7'
  section     'devel'
  arch        'amd64'

  source "https://storage.googleapis.com/golang/go#{version}.linux-amd64.tar.gz"

  post_install  'scripts/post-install'
  pre_uninstall 'scripts/pre-uninstall'

  conflicts 'golang', 'golang-go', 'golang-src', 'golang-doc'
  replaces 'golang', 'golang-go', 'golang-src', 'golang-doc'

  def build; end

  def install
    # install into grindr location
    destdir('/usr/lib64/go').install(Dir['*'])
  end
end
