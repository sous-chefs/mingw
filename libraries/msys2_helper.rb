# frozen_string_literal: true

module Mingw
  module MSYS2Helper
    def bash_command(command)
      "\"#{::File.join(new_resource.root, 'usr/bin/bash.exe')}\" --login -c \"#{command}\""
    end

    def msys_environment
      { 'MSYSTEM' => 'MSYS', 'CHERE_INVOKING' => '1', 'MSYS2_PATH_TYPE' => 'minimal',
        'HOME' => "/home/#{ENV['USERNAME'] || ENV['USER']}" }
    end

    def installed_targets
      return [] unless ::File.exist?(::File.join(new_resource.root, 'usr/bin/pacman.exe'))

      options = { environment: msys_environment }
      return [new_resource.package] if shell_out(bash_command("pacman -Q -- #{new_resource.package}"), **options).exitstatus.zero?

      group = shell_out(bash_command("pacman -Qgq -- #{new_resource.package}"), **options)
      return [] unless group.exitstatus.zero?

      members = group.stdout.split.uniq
      raise ArgumentError, 'Invalid local MSYS2 group member' unless members.all? { |name| name.match?(/\A[\w.+-]+\z/) }

      members
    end

    def package_installed?
      return false unless ::File.exist?(::File.join(new_resource.root, 'usr/bin/pacman.exe'))

      options = { environment: msys_environment }
      return true if shell_out(bash_command("pacman -Q -- #{new_resource.package}"), **options).exitstatus.zero?

      group = shell_out(bash_command("pacman -Sgq -- #{new_resource.package}"), **options)
      members = group.stdout.split
      return false unless group.exitstatus.zero? && !members.empty?

      shell_out(bash_command("pacman -Q -- #{members.join(' ')}"), **options).exitstatus.zero?
    end
  end
end
