# frozen_string_literal: true
#
# Cookbook:: mingw
# Resource:: msys2_package
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

provides :msys2_package

property :package, String, name_property: true
property :root, String, required: true
property :source_url, String,
  default: 'http://downloads.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-20160205.tar.xz'
property :checksum, String,
  default: '7e97e2af042e1b6f62cf0298fe84839014ef3d4a3e7825cffc6931c66cc0fc20'

action_class do
  include Mingw::Helpers

  def msys2_init
    cache_dir = ::File.join(new_resource.root, '.cache')
    f_cache_dir = win_friendly_path(cache_dir)
    archive_path = ::File.join(f_cache_dir, archive_name(new_resource.source_url))

    directory f_cache_dir do
      recursive true
    end

    remote_file "cache msys2 base to #{f_cache_dir}" do
      path archive_path
      source new_resource.source_url
      checksum new_resource.checksum
    end

    archive_file "extract msys2 base archive to #{f_cache_dir}" do
      path archive_path
      destination f_cache_dir
    end

    ruby_block 'copy msys2 base files to root' do
      block do
        ::FileUtils.cp_r(::Dir.glob("#{cache_dir}/msys64/*"), new_resource.root, preserve: true)
      end
      not_if { ::File.exist?(::File.join(new_resource.root, 'msys2.exe')) }
    end

    bin_dir = ::File.join(new_resource.root, 'bin')
    f_bin_dir = win_friendly_path(bin_dir)

    directory f_bin_dir

    template "#{f_bin_dir}\\bash.bat" do
      source 'bash.bat.erb'
      cookbook 'mingw'
    end

    template win_friendly_path(::File.join(new_resource.root, 'custom-upgrade.sh')) do
      source 'custom-upgrade.sh.erb'
      cookbook 'mingw'
    end

    template win_friendly_path(::File.join(new_resource.root, 'etc/profile.d/custom_prefix.sh')) do
      source 'custom_prefix.sh.erb'
      cookbook 'mingw'
    end

    pacman_key_dir = ::File.join(new_resource.root, 'etc/pacman.d/gnupg')
    msys2_exec('msys2 first time init', 'exit') unless ::File.exist?(pacman_key_dir)

    if ::File.exist?(::File.join(new_resource.root, 'usr/bin/update-core')) ||
       !::File.exist?(::File.join(new_resource.root, 'custom-upgrade.sh'))
      msys2_exec('upgrade msys2 core', '/custom-upgrade.sh')
      msys2_exec('upgrade msys2 core: part 2', 'pacman -Suu --noconfirm')
      msys2_exec('upgrade entire msys2 system: 1', 'pacman -Syuu --noconfirm')
      msys2_exec('upgrade entire msys2 system: 2', 'pacman -Syuu --noconfirm')
    end
  end

  def msys2_exec(comment, cmd)
    f_root = win_friendly_path(new_resource.root)
    execute comment do
      command ".\\bin\\bash.bat -c '#{cmd}'"
      cwd f_root
      live_stream true
      environment('MSYSTEM' => 'MSYS')
    end
  end
end

action :install do
  msys2_init
  msys2_exec("installing #{new_resource.package}",
             "pacman -S --needed --noconfirm #{new_resource.package}")
end

action :upgrade do
  msys2_init
  msys2_exec("upgrading #{new_resource.package}",
             "pacman -Syu --noconfirm #{new_resource.package}")
end

action :remove do
  msys2_init
  msys2_exec("removing #{new_resource.package}",
             "pacman -R --noconfirm #{new_resource.package}")
end
