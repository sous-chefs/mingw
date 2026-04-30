# frozen_string_literal: true

require 'spec_helper'

describe 'mingw_tdm_gcc' do
  step_into :mingw_tdm_gcc
  platform 'windows', '2019'

  context 'installing 64-bit TDM-GCC' do
    recipe do
      mingw_tdm_gcc '5.1.0' do
        root 'C:\\mingw64'
        flavor :seh_sjlj_64
      end
    end

    it { is_expected.to create_directory('C:\\mingw64\\.cache') }
    it { is_expected.to create_remote_file('cache gcc-5.1.0-tdm64-1-core.tar.lzma to C:\\mingw64\\.cache').with(checksum: '29393aac890847089ad1e93f81a28f6744b1609c00b25afca818f3903e42e4bd') }
    it { is_expected.to extract_archive_file('extract gcc-5.1.0-tdm64-1-core.tar to C:\\mingw64').with(destination: 'C:\\mingw64') }
  end

  context 'installing 32-bit TDM-GCC' do
    recipe do
      mingw_tdm_gcc '5.1.0' do
        root 'C:\\mingw32'
        flavor :sjlj_32
      end
    end

    it { is_expected.to install_mingw_get('install binutils-bin=2.25.1 at C:\\mingw32') }
    it { is_expected.to create_template('C:\\mingw32\\include\\pthread.h').with(source: 'pthread.h.erb') }
    it { is_expected.to create_template('C:\\mingw32\\include\\time.h').with(source: 'time.h.erb') }
  end
end
