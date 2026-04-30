# frozen_string_literal: true
#
# Cookbook:: mingw
# Resource:: tdm_gcc
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

provides :mingw_tdm_gcc

property :flavor, Symbol, equal_to: %i(sjlj_32 seh_sjlj_64), default: :seh_sjlj_64
property :root, String, required: true
property :version, String, equal_to: ['5.1.0'], name_property: true

action_class do
  include Mingw::Helpers

  def tdm_gcc_archives_for(flavor)
    case flavor
    when :seh_sjlj_64
      {
        'http://iweb.dl.sourceforge.net/project/tdm-gcc/TDM-GCC%205%20series/5.1.0-tdm64-1/gcc-5.1.0-tdm64-1-core.tar.lzma' =>
          '29393aac890847089ad1e93f81a28f6744b1609c00b25afca818f3903e42e4bd',
        'http://iweb.dl.sourceforge.net/project/tdm-gcc/MinGW-w64%20runtime/GCC%205%20series/mingw64runtime-v4-git20150618-gcc5-tdm64-1.tar.lzma' =>
          '29186e0bb36824b10026d78bdcf238d631d8fc1d90718d2ebbd9ec239b6f94dd',
        'http://iweb.dl.sourceforge.net/project/tdm-gcc/GNU%20binutils/binutils-2.25-tdm64-1.tar.lzma' =>
          '4722bb7b4d46cef714234109e25e5d1cfd29f4e53365b6d615c8a00735f60e40',
        'http://iweb.dl.sourceforge.net/project/tdm-gcc/TDM-GCC%205%20series/5.1.0-tdm64-1/gcc-5.1.0-tdm64-1-c%2B%2B.tar.lzma' =>
          '17fd497318d1ac187a113e8665330d746ad9607a0406ab2374db0d8e6f4094d1',
      }
    when :sjlj_32
      {
        'http://iweb.dl.sourceforge.net/project/tdm-gcc/TDM-GCC%205%20series/5.1.0-tdm-1%20SJLJ/gcc-5.1.0-tdm-1-core.tar.lzma' =>
          '9199e6ecbce956ff4704b52098beb38e313176ace610285fb93758a08752870e',
        'http://iweb.dl.sourceforge.net/project/tdm-gcc/TDM-GCC%205%20series/5.1.0-tdm-1%20SJLJ/gcc-5.1.0-tdm-1-c%2B%2B.tar.lzma' =>
          '19fe46819ce43531d066b438479300027bbf06da57e8a10be5100466f80c28fc',
      }
    end
  end
end

action :install do
  f_cache_dir = win_friendly_path(::File.join(new_resource.root, '.cache'))
  f_root = win_friendly_path(new_resource.root)

  directory f_cache_dir do
    recursive true
  end

  if new_resource.flavor == :sjlj_32
    %w(
      binutils-bin=2.25.1
      libintl-dll=0.18.3.2
      mingwrt-dll=3.21.1
      mingwrt-dev=3.21.1
      w32api-dev=3.17
    ).each do |fragment|
      mingw_get "install #{fragment} at #{f_root}" do
        package "mingw32-#{fragment}-*"
        root new_resource.root
      end
    end
  end

  tdm_gcc_archives_for(new_resource.flavor).each do |url, hash|
    archive_path = ::File.join(f_cache_dir, archive_name(url))

    remote_file "cache #{archive_name(url)} to #{f_cache_dir}" do
      path archive_path
      source url
      checksum hash
    end

    archive_file "extract #{tar_name(url)} to #{f_root}" do
      path archive_path
      destination f_root
    end
  end

  if new_resource.flavor == :sjlj_32
    include_dir = win_friendly_path(::File.join(new_resource.root, 'include'))

    template "#{include_dir}\\pthread.h" do
      cookbook 'mingw'
      source 'pthread.h.erb'
    end

    template "#{include_dir}\\time.h" do
      cookbook 'mingw'
      source 'time.h.erb'
    end
  end
end

action :remove do
  directory new_resource.root do
    action :delete
    recursive true
  end
end
