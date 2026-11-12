# frozen_string_literal: true

provides :mingw_tdm_gcc
unified_mode true

property :flavor, Symbol, equal_to: [:sjlj_32, :seh_sjlj_64], default: :seh_sjlj_64
use '_partial/_root'
property :version, String, equal_to: ['5.1.0'], name_property: true

action_class do
  include Mingw::Helper

  def install_marker
    Mingw::TDMReceipt.path(new_resource.root, new_resource.version, new_resource.flavor)
  end
end

action :install do
  marker = install_marker
  install_root = new_resource.root
  runner = method(:shell_out!)
  existing = Mingw::TDMOwnership.read(install_root, marker, audit: runner)
  receipt_data = existing
  root_created = !::File.exist?(install_root)
  before = nil
  ruby_block "prepare protected TDM state for #{install_root}" do
    block { Mingw::TDMReceipt.audit!(runner, 'ensure') }
    only_if { existing.nil? }
  end
  directory new_resource.root do
    recursive true
  end
  if new_resource.flavor == :sjlj_32
    %w(binutils-bin=2.25.1 libintl-dll=0.18.3.2 mingwrt-dll=3.21.1 mingwrt-dev=3.21.1 w32api-dev=3.17).each do |fragment|
      mingw_get "mingw32-#{fragment}-*" do
        root new_resource.root
      end
    end
  end

  # Dependencies can share this root; they are not TDM-owned artifacts.
  ruby_block "inventory TDM installation at #{install_root}" do
    block do
      begin
        Mingw::TDMReceipt.audit!(runner, 'tree', root: install_root)
        candidate = Mingw::TDMOwnership.inventory(install_root)
        before = candidate if candidate[:identity]['inode'].positive?
      rescue Mixlib::ShellOut::ShellCommandFailed
        Chef::Log.warn('TDM installation can continue, but this root is not trusted for automatic removal')
      end
    end
    only_if { existing.nil? }
  end

  archives = new_resource.flavor == :sjlj_32 ? Mingw::TDM_GCC_32 : Mingw::TDM_GCC_64
  archives.each do |url, hash|
    cache = ::File.join(Chef::Config[:file_cache_path], archive_name(url))
    remote_file cache do
      source url
      checksum hash
      not_if { existing }
    end
    archive_file cache do
      destination new_resource.root
      overwrite true
      not_if { existing }
    end
  end

  if new_resource.flavor == :sjlj_32
    %w(pthread.h time.h).each do |header|
      template ::File.join(new_resource.root, 'include', header) do
        cookbook 'mingw'
        source "#{header}.erb"
      end
    end
  end
  ruby_block "record TDM ownership for #{install_root}" do
    block do
      receipt_data = Mingw::TDMOwnership.unsupported(install_root, root_created)
      if before
        begin
          Mingw::TDMReceipt.audit!(runner, 'tree', root: install_root)
          receipt_data = Mingw::TDMOwnership.build(install_root, before, root_created, trusted: true)
        rescue Mixlib::ShellOut::ShellCommandFailed
          Chef::Log.warn('TDM removal ownership was not recorded because path permissions are not trusted')
        end
      end
    end
    only_if { existing.nil? }
  end
  file marker do
    content lazy { "#{JSON.pretty_generate(receipt_data || {})}\n" }
    owner 'S-1-5-32-544'
    rights :full_control, ['S-1-5-18', 'S-1-5-32-544']
    inherits false
    sensitive true
  end
end

# Remove only unchanged files created by this installation. Never recurse over
# the root: MinGW/MSYS packages and user files may share it.
action :remove do
  marker = install_marker
  install_root = new_resource.root
  runner = method(:shell_out!)
  manifest = Mingw::TDMOwnership.read(install_root, marker, audit: runner)
  next unless manifest

  Mingw::TDMOwnership.validate!(install_root, manifest, removing: true)
  Mingw::TDMReceipt.audit!(runner, 'removal', root: install_root, receipt: marker)
  plan = Mingw::TDMOwnership.plan(install_root, manifest)
  plan[:files].each do |relative|
    file ::File.join(install_root, relative) do
      action :delete
      only_if { Mingw::TDMOwnership.removable_file?(install_root, manifest, relative) }
    end
  end
  plan[:directories].each do |relative|
    directory ::File.join(install_root, relative) do
      recursive false
      action :delete
      only_if { Mingw::TDMOwnership.empty_directory?(install_root, manifest, relative) }
    end
  end
  file marker do
    action :delete
  end
  directory install_root do
    recursive false
    action :delete
    only_if { manifest['root_created'] && Mingw::TDMOwnership.empty_directory?(install_root, manifest) }
  end
  Chef::Log.warn('Retained TDM file entries whose content changed or disappeared') unless plan[:preserved].empty?
end
