# frozen_string_literal: true

root = 'C:/mingw-test-upgrade'
cache = File.join(Chef::Config[:file_cache_path], 'msys2-upgrade-seed.tar.zst')
# Seed an existing installation without the resource bootstrap updates. Keep this
# fixture pinned so later upstream core updates exercise the upgrade restart path.
unless File.exist?(File.join(root, 'usr/bin/pacman.exe'))
  remote_file cache do
    source 'https://github.com/msys2/msys2-installer/releases/download/2026-09-27/msys2-base-x86_64-20260927.tar.zst'
    checksum '8a2095647afbf799d113d0cae35f7544589d059819042635504e75bd2179bd02'
  end
  archive_file cache do
    destination root
    strip_components 1
    overwrite true
  end
end
execute 'record existing MSYS2 core versions before upgrade' do
  command "\"#{root}/usr/bin/bash.exe\" --login -c \"pacman -Q bash pacman msys2-runtime\""
  environment('MSYSTEM' => 'MSYS', 'MSYS2_PATH_TYPE' => 'minimal',
              'HOME' => "/home/#{ENV['USERNAME']}")
  live_stream true
end
msys2_package 'make' do
  root root
  action :upgrade
end
