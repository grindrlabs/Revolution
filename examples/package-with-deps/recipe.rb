# frozen_string_literal: true

class PackageWithDeps < FPM::Cookery::Recipe
  name        'package-with-deps'
  description 'Project containing multiple packages for testing'
  homepage    'https://medium.com/@GrindrLabs'
  maintainer  'ISRE <isre@grindr.com>'

  source File.join(File.dirname(__FILE__), 'README.md'), with: 'local_path'

  version     '0.0.1'
  revision    '1'

  depends     'golang'

  def build; end

  def install; end
end
