name 'mingw'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'apache2'
description 'Installs a mingw/msys based toolchain on windows'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.1'

supports 'windows'

depends 'seven_zip'

source_url 'https://github.com/chef-cookbooks/mingw'
issues_url 'https://github.com/chef-cookbooks/mingw/issues'
