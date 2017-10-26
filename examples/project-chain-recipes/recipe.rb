#!/usr/bin/env ruby

class ProjectChainRecipes < FPM::Cookery::Recipe

  name        'project-chain-recipes'
  description 'Project containing multiple packages for testing'
  homepage    'https://medium.com/@GrindrLabs'
  maintainer  'ISRE <isre@grindr.com>'

  source File.join(File.dirname(__FILE__), "README.md"), with: 'local_path'

  version     '0.0.1'
  revision    '1'

  depends     'golang', 'package-with-deps'
  chain_package true
  chain_recipes 'test'

  def build
  end

  def install
  end
end
