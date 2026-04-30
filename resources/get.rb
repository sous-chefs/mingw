# frozen_string_literal: true
#
# Cookbook:: mingw
# Resource:: get
#
# Copyright:: 2016-2026, Sous Chefs
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#

unified_mode true

provides :mingw_get

property :package, String, name_property: true
property :root, String, required: true
property :source_url, String,
  default: 'http://iweb.dl.sourceforge.net/project/mingw/Installer/mingw-get/mingw-get-0.6.2-beta-20131004-1/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip'
property :checksum, String,
  default: '2e0e9688d42adc68c5611759947e064156e169ff871816cae52d33ee0655826d'

action_class do
  include Mingw::Helpers

  def fetch_mingw_get
    f_cache_dir = win_friendly_path(::File.join(new_resource.root, '.cache'))
    f_root = win_friendly_path(new_resource.root)
    archive_path = ::File.join(f_cache_dir, archive_name(new_resource.source_url))

    directory f_cache_dir do
      recursive true
    end

    remote_file "cache mingw-get to #{f_cache_dir}" do
      path archive_path
      source new_resource.source_url
      checksum new_resource.checksum
    end

    archive_file "extract mingw-get to #{f_root}" do
      path archive_path
      destination f_root
    end
  end

  def mingw_do_action(action_cmd)
    fetch_mingw_get

    f_root = win_friendly_path(new_resource.root)
    execute "performing #{action_cmd} for #{new_resource.package}" do
      command ".\\bin\\mingw-get.exe -v #{action_cmd} #{new_resource.package}"
      cwd f_root
    end
  end
end

action :install do
  mingw_do_action('install')
end

action :upgrade do
  mingw_do_action('upgrade')
end

action :remove do
  mingw_do_action('remove')
end
