# frozen_string_literal: true

provides :msys2_package
unified_mode true

property :package, String, name_property: true, regex: /\A[\w.+-]+\z/
use '_partial/_root'
property :url, String, default: 'https://github.com/msys2/msys2-installer/releases/download/2026-09-27/msys2-base-x86_64-20260927.tar.zst'
property :checksum, String, default: '8a2095647afbf799d113d0cae35f7544589d059819042635504e75bd2179bd02'

action_class do
  include Mingw::Helper

  def bash_command(command)
    "\"#{::File.join(new_resource.root, 'usr/bin/bash.exe')}\" --login -c \"#{command}\""
  end

  def package_installed?
    return false unless ::File.exist?(::File.join(new_resource.root, 'usr/bin/pacman.exe'))

    options = { environment: { 'MSYSTEM' => 'MSYS', 'CHERE_INVOKING' => '1' } }
    return true if shell_out(bash_command("pacman -Q -- #{new_resource.package}"), **options).exitstatus.zero?

    group = shell_out(bash_command("pacman -Sgq -- #{new_resource.package}"), **options)
    members = group.stdout.split
    return false unless group.exitstatus.zero? && !members.empty?

    shell_out(bash_command("pacman -Q -- #{members.join(' ')}"), **options).exitstatus.zero?
  end

  def bootstrap
    fresh = !::File.exist?(::File.join(new_resource.root, 'usr/bin/pacman.exe'))
    directory new_resource.root do
      recursive true
    end
    if fresh
      cache = ::File.join(Chef::Config[:file_cache_path], archive_name(new_resource.url))
      remote_file cache do
        source new_resource.url
        checksum new_resource.checksum
      end
      archive_file cache do
        destination new_resource.root
        strip_components 1
        overwrite true
      end
    end

    directory ::File.join(new_resource.root, 'bin')
    { 'bin/bash.bat' => 'bash.bat.erb', 'etc/profile.d/custom_prefix.sh' => 'custom_prefix.sh.erb' }.each do |path, source_file|
      template ::File.join(new_resource.root, path) do
        cookbook 'mingw'
        source source_file
      end
    end

    if fresh
      # Restart the login shell between core updates, as required by MSYS2.
      2.times do |pass|
        execute "initial MSYS2 update #{pass + 1} in #{new_resource.root}" do
          command bash_command('pacman -Syu --noconfirm')
          environment('MSYSTEM' => 'MSYS', 'CHERE_INVOKING' => '1')
        end
      end
    end
  end

  def package_action(verb)
    provider = self
    execute "MSYS2 #{verb} #{new_resource.package} in #{new_resource.root}" do
      command bash_command("pacman #{verb} --noconfirm -- #{new_resource.package}")
      environment('MSYSTEM' => 'MSYS', 'CHERE_INVOKING' => '1')
      not_if { provider.package_installed? } if verb == '-S --needed'
      only_if { provider.package_installed? } if verb == '-R'
    end
  end
end

action :install do
  bootstrap
  package_action('-S --needed')
end

action :upgrade do
  bootstrap
  package_action('-Syu')
end

# Other package resources may share this MSYS2 installation.
action :remove do
  package_action('-R')
end
