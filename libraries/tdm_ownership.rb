# frozen_string_literal: true

require 'digest'
require 'find'
require 'json'
require_relative '_helper'

module Mingw
  module TDMOwnership
    def self.identity(root)
      link = ::File.lstat(root).symlink?
      stat = ::File.stat(root)
      raise ArgumentError, 'Cannot identify the TDM directory' unless stat.directory? && stat.ino.positive?

      realpath = ::File.realpath(root).tr('\\', '/')
      realpath = realpath.downcase if ::File::ALT_SEPARATOR == '\\'
      { 'realpath' => realpath, 'device' => stat.dev, 'inode' => stat.ino, 'symlink' => link }
    end

    def self.inventory(root)
      base = ::File.realpath(root)
      prefix = "#{base.tr('\\', '/').delete_suffix('/')}/"
      entries = []
      files = []
      directories = []
      Find.find(base, ignore_error: false) do |path|
        next if path == base

        relative = path.tr('\\', '/').delete_prefix(prefix)
        entries << relative
        stat = ::File.lstat(path)
        if stat.symlink?
          Find.prune
        elsif stat.directory?
          directories << relative
        elsif stat.file?
          files << relative
        end
      end
      { entries: entries, files: files, directories: directories, identity: identity(root) }
    end

    def self.build(root, before, root_created)
      after = inventory(root)
      raise ArgumentError, 'TDM root changed during installation' unless before[:identity] == after[:identity]

      files = (after[:files] - before[:entries]).to_h do |relative|
        [relative, Digest::SHA256.file(::File.join(root, relative)).hexdigest]
      end
      { 'schema' => 1, 'root' => after[:identity], 'root_created' => root_created,
        'files' => files, 'directories' => after[:directories] - before[:entries] }
    end

    def self.relative_path!(relative)
      unless relative.is_a?(String) && !relative.include?('\\') &&
             !relative.start_with?('/') && Mingw::Helper.valid_install_root?("C:/#{relative}")
        raise ArgumentError, 'Invalid TDM ownership path'
      end
    end

    def self.validate!(root, manifest, removing: false)
      unless manifest.is_a?(Hash) && manifest['schema'] == 1 && manifest['files'].is_a?(Hash) &&
             manifest['directories'].is_a?(Array) && [true, false].include?(manifest['root_created'])
        raise ArgumentError, 'Unrecognised TDM ownership manifest; refusing removal'
      end
      validate_root!(root, manifest, removing: removing)

      manifest['files'].each do |relative, checksum|
        relative_path!(relative)
        raise ArgumentError, 'Invalid TDM file fingerprint' unless checksum.is_a?(String) && checksum.match?(/\A[0-9a-f]{64}\z/)
      end
      manifest['directories'].each { |relative| relative_path!(relative) }
    end

    def self.validate_root!(root, manifest, removing: false)
      current = identity(root)
      raise ArgumentError, 'TDM root identity changed; refusing removal' unless current == manifest['root']
      raise ArgumentError, 'TDM removal through a symlink is not supported' if removing && current['symlink']
    end

    def self.read(root, marker)
      return unless ::File.exist?(marker) || ::File.symlink?(marker)

      raise ArgumentError, 'TDM ownership manifest is not a regular file' unless ::File.lstat(marker).file? && !::File.symlink?(marker)

      manifest = JSON.parse(::File.read(marker))
      validate!(root, manifest)
      manifest
    rescue JSON::ParserError
      raise ArgumentError, 'Unrecognised TDM ownership manifest; refusing removal'
    end

    def self.safe_parents!(root, relative)
      relative_path!(relative)
      current = root
      relative.split('/')[0...-1].each do |part|
        current = ::File.join(current, part)
        return false unless ::File.exist?(current) || ::File.symlink?(current)

        stat = ::File.lstat(current)
        raise ArgumentError, 'Redirected TDM ownership path; refusing removal' if stat.symlink? || !stat.directory?

        real = ::File.realpath(current).tr('\\', '/')
        base = ::File.realpath(root).tr('\\', '/')
        if ::File::ALT_SEPARATOR == '\\'
          real = real.downcase
          base = base.downcase
        end
        raise ArgumentError, 'TDM path escaped its root; refusing removal' unless real.start_with?("#{base.delete_suffix('/')}/")
      end
      true
    end

    def self.removable_file?(root, manifest, relative)
      validate_root!(root, manifest, removing: true)
      return false unless safe_parents!(root, relative)

      path = ::File.join(root, relative)
      return false unless ::File.exist?(path) || ::File.symlink?(path)

      stat = ::File.lstat(path)
      stat.file? && !stat.symlink? && Digest::SHA256.file(path).hexdigest == manifest['files'].fetch(relative)
    end

    def self.plan(root, manifest)
      validate!(root, manifest, removing: true)
      files = manifest['files'].keys.select { |relative| removable_file?(root, manifest, relative) }
      # Validate every directory before declaring any destructive Chef resource.
      manifest['directories'].each { |relative| safe_parents!(root, relative) }
      { files: files, directories: manifest['directories'].sort_by { |relative| -relative.count('/') },
        preserved: manifest['files'].keys - files }
    end

    def self.empty_directory?(root, manifest, relative = nil)
      validate_root!(root, manifest, removing: true)
      return false if relative && !safe_parents!(root, relative)

      path = relative ? ::File.join(root, relative) : root
      return false unless ::File.directory?(path) && !::File.symlink?(path)

      ::Dir.empty?(path)
    end
  end
end
