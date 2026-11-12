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

  archives = new_resource.flavor == :sjlj_32 ? Mingw::TDM_GCC_32 : Mingw::TDM_GCC_64
  archives.each do |url, hash|
    cache = ::File.join(Chef::Config[:file_cache_path], archive_name(url))
    remote_file cache do
      source url
      checksum hash
      not_if { ::File.exist?(marker) }
    end
    archive_file cache do
      destination new_resource.root
      overwrite true
      not_if { ::File.exist?(marker) }
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
    content "#{new_resource.version} #{new_resource.flavor}\n"
  end
end

# The caller must dedicate root to this toolchain; unmarked directories are retained.
action :remove do
  marker = install_marker
  directory new_resource.root do
    recursive true
    action :delete
    only_if { ::File.exist?(marker) }
  end
end
