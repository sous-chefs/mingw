name 'mingw'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache-2.0'
description 'Installs a mingw/msys based toolchain on windows'
version '2.1.1'

supports 'windows'

depends 'seven_zip'

source_url 'https://github.com/chef-cookbooks/mingw'
issues_url 'https://github.com/chef-cookbooks/mingw/issues'
chef_version '>= 12.15'
