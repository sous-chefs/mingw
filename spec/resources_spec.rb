# frozen_string_literal: true

require 'spec_helper'

describe 'mingw_get' do
  platform 'windows', '2022'
  step_into :mingw_get
  recipe do
    mingw_get 'msys-base' do
      root 'C:/mingw'
    end
  end
  it 'downloads a verified bootstrap and extracts it natively' do
    expect(chef_run.find_resources(:remote_file).first.checksum).to eq('2e0e9688d42adc68c5611759947e064156e169ff871816cae52d33ee0655826d')
    expect(chef_run.find_resources(:archive_file).first.destination).to eq('C:/mingw')
  end
  it 'requests the named package' do
    expect(chef_run).to run_execute('mingw-get install msys-base in C:/mingw')
  end
end

describe 'mingw_tdm_gcc' do
  platform 'windows', '2022'
  step_into :mingw_tdm_gcc
  recipe do
    mingw_tdm_gcc '5.1.0' do
      root 'C:/mingw64'
    end
  end
  it 'retains every verified64-bit compiler component' do
    expect(chef_run.find_resources(:archive_file).size).to eq(4)
    expect(chef_run.find_resources(:remote_file).map(&:checksum)).to all(match(/\A[0-9a-f]{64}\z/))
  end
  context '32-bit SJLJ' do
    recipe do
      mingw_tdm_gcc '5.1.0' do
        root 'C:/mingw32'
        flavor :sjlj_32
      end
    end
    it 'retains32-bit runtime packages and patched headers' do
      expect(chef_run.find_resources(:mingw_get).size).to eq(5)
      expect(chef_run).to create_template('C:/mingw32/include/pthread.h')
      expect(chef_run).to create_template('C:/mingw32/include/time.h')
    end
  end
end

describe 'msys2_package' do
  platform 'windows', '2022'
  step_into :msys2_package
  recipe do
    msys2_package 'make' do
      root 'C:/msys2'
    end
  end
  it 'uses the approved pinned base with native extraction' do
    expect(chef_run.find_resources(:remote_file).first.source.first).to include('20260927.tar.zst')
    expect(chef_run.find_resources(:archive_file).first.strip_components).to eq(1)
  end
  it 'retains the shell shim and prefix environment integration' do
    expect(chef_run).to create_template('C:/msys2/bin/bash.bat')
    expect(chef_run).to create_template('C:/msys2/etc/profile.d/custom_prefix.sh')
  end
  context 'custom source' do
    recipe do
      msys2_package 'make' do
        root 'C:/msys2'
        url 'https://example.test/custom.tar.xz'
        checksum 'a' * 64
      end
    end
    it 'keeps explicit URL and checksum settings' do
      expect(chef_run.find_resources(:remote_file).first.source).to eq(['https://example.test/custom.tar.xz'])
      expect(chef_run.find_resources(:remote_file).first.checksum).to eq('a' * 64)
    end
  end
end

describe 'package removal' do
  platform 'windows', '2022'
  step_into :mingw_get, :msys2_package
  recipe do
    mingw_get 'absent' do
      root 'C:/not-installed'
      action :remove
    end
    msys2_package 'absent' do
      root 'C:/not-installed'
      action :remove
    end
  end
  it 'does not download or extract a bootstrap to remove an absent package' do
    expect(chef_run.find_resources(:remote_file)).to be_empty
    expect(chef_run.find_resources(:archive_file)).to be_empty
    expect(chef_run.find_resources(:execute)).to all(satisfy { |resource| !resource.updated_by_last_action? })
  end
end
