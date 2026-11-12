# frozen_string_literal: true

provides :mingw_get
unified_mode true

property :package, String, name_property: true, regex: /\A[\w.+*?=-]+\z/
use '_partial/_root'
property :source, String, default: 'https://downloads.sourceforge.net/project/mingw/Installer/mingw-get/mingw-get-0.6.2-beta-20131004-1/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip'
property :checksum, String, default: '2e0e9688d42adc68c5611759947e064156e169ff871816cae52d33ee0655826d'

action_class do
  include Mingw::Helper

  def bootstrap
    directory new_resource.root do
      recursive true
    end
    cache = ::File.join(Chef::Config[:file_cache_path], 'mingw-get-0.6.2.zip')
    remote_file cache do
      source new_resource.source
      checksum new_resource.checksum
      not_if { ::File.exist?(::File.join(new_resource.root, 'bin/mingw-get.exe')) }
    end
    archive_file cache do
      destination new_resource.root
      overwrite true
      not_if { ::File.exist?(::File.join(new_resource.root, 'bin/mingw-get.exe')) }
    end
  end

  def package_action(verb)
    provider = self
    execute "mingw-get #{verb} #{new_resource.package} in #{new_resource.root}" do
      command "\"#{::File.join(new_resource.root, 'bin/mingw-get.exe')}\" -v #{verb} #{new_resource.package}"
      cwd new_resource.root
      if verb == 'install'
        not_if { provider.mingw_package_installed? }
      elsif verb == 'remove'
        only_if { provider.mingw_package_installed? }
      end
    end
  end
end

action :install do
  bootstrap
  package_action('install')
end

action :upgrade do
  bootstrap
  package_action('upgrade')
end

# Removal retains the shared package manager and other installed packages.
action :remove do
  package_action('remove')
end
