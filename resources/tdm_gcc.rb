#
# Cookbook Name:: mingw
# Resource:: tdm_gcc
#
# Copyright 2016, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Installs a gcc based C/C++ compiler and runtime from TDM GCC.

property :flavor, kind_of: Symbol, is: [:sjlj_32, :seh_sjlj_64], default: :seh_sjlj_64
property :root, kind_of: String, required: true
property :version, kind_of: String, is: ['5.1.0'], name_property: true

default_action :install

tdm_gcc_64 = {
  'http://iweb.dl.sourceforge.net/project/tdm-gcc/TDM-GCC%205%20series/5.1.0-tdm64-1/gcc-5.1.0-tdm64-1-core.tar.lzma' =>
    '29393aac890847089ad1e93f81a28f6744b1609c00b25afca818f3903e42e4bd',
  'http://iweb.dl.sourceforge.net/project/tdm-gcc/MinGW-w64%20runtime/GCC%205%20series/mingw64runtime-v4-git20150618-gcc5-tdm64-1.tar.lzma' =>
    '29186e0bb36824b10026d78bdcf238d631d8fc1d90718d2ebbd9ec239b6f94dd',
  'http://iweb.dl.sourceforge.net/project/tdm-gcc/GNU%20binutils/binutils-2.25-tdm64-1.tar.lzma' =>
    '4722bb7b4d46cef714234109e25e5d1cfd29f4e53365b6d615c8a00735f60e40',
  'http://iweb.dl.sourceforge.net/project/tdm-gcc/TDM-GCC%205%20series/5.1.0-tdm64-1/gcc-5.1.0-tdm64-1-c%2B%2B.tar.lzma' =>
    '17fd497318d1ac187a113e8665330d746ad9607a0406ab2374db0d8e6f4094d1'
}

tdm_gcc_32 = {
  'http://iweb.dl.sourceforge.net/project/tdm-gcc/TDM-GCC%205%20series/5.1.0-tdm-1%20SJLJ/gcc-5.1.0-tdm-1-core.tar.lzma' =>
    '000',
  'http://iweb.dl.sourceforge.net/project/mingw/MinGW/Base/binutils/binutils-2.24/binutils-2.24-1-mingw32-bin.tar.xz' =>
    '000',
  'http://iweb.dl.sourceforge.net/project/mingw/MinGW/Base/gettext/gettext-0.18.3.2-1/libintl-0.18.3.2-1-mingw32-dll-8.tar.xz' =>
    '000',
  'http://iweb.dl.sourceforge.net/project/mingw/MinGW/Base/mingwrt/mingwrt-3.20/mingwrt-3.20-2-mingw32-dev.tar.lzma' =>
    '000',
  'http://iweb.dl.sourceforge.net/project/mingw/MinGW/Base/mingwrt/mingwrt-3.20/mingwrt-3.20-2-mingw32-dll.tar.lzma' =>
    '000',
  'http://iweb.dl.sourceforge.net/project/mingw/MinGW/Base/w32api/w32api-3.17/w32api-3.17-2-mingw32-dev.tar.lzma' =>
    '000',
  'http://iweb.dl.sourceforge.net/project/tdm-gcc/TDM-GCC%205%20series/5.1.0-tdm-1%20SJLJ/gcc-5.1.0-tdm-1-c%2B%2B.tar.lzma' =>
    '000'
}

action :install do
  cache_dir = File.join(root, '.cache')

  to_fetch =
    case flavor
    when :sjlj_32
      tdm_gcc_32
    when :seh_sjlj_64
      tdm_gcc_64
    else
      raise "Unknown flavor: #{flavor}"
    end

  to_fetch.each do |url, hash|
    seven_zip_archive archive_name(url) do
      source url
      path cache_dir
      overwrite true
      checksum hash
    end

    seven_zip_archive tar_name(url) do
      source File.join(cache_dir, tar_name(url))
      path root
      overwrite true
    end
  end
end
