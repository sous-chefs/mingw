# frozen_string_literal: true

provides :mingw_tdm_gcc
unified_mode true

property :flavor, Symbol, equal_to: [:sjlj_32, :seh_sjlj_64], default: :seh_sjlj_64
use '_partial/_root'
property :version, String, equal_to: ['5.1.0'], name_property: true

action_class do
  include Mingw::Helper

  def install_marker
    ::File.join(new_resource.root, ".mingw-tdm-#{new_resource.version}-#{new_resource.flavor}")
  end
end

action :install do
  marker = install_marker
  install_root = new_resource.root
  existing = Mingw::TDMOwnership.read(install_root, marker)
  root_created = !::File.exist?(install_root)
  before = nil
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
    block { before = Mingw::TDMOwnership.inventory(install_root) }
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
  file install_marker do
    content lazy {
      manifest = existing || (before && Mingw::TDMOwnership.build(install_root, before, root_created))
      "#{JSON.pretty_generate(manifest || {})}\n"
    }
    sensitive true
  end
end

# Remove only unchanged files created by this installation. Never recurse over
# the root: MinGW/MSYS packages and user files may share it.
action :remove do
  marker = install_marker
  install_root = new_resource.root
  manifest = Mingw::TDMOwnership.read(install_root, marker)
  next unless manifest

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
