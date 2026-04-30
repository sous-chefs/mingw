# frozen_string_literal: true

require 'spec_helper'

describe 'msys2_package' do
  step_into :msys2_package
  platform 'windows', '2019'

  context 'installing a package with defaults' do
    recipe do
      msys2_package 'base-devel' do
        root 'C:\\msys2'
      end
    end

    it { is_expected.to create_directory('C:\\msys2\\.cache') }
    it { is_expected.to create_remote_file('cache msys2 base to C:\\msys2\\.cache').with(source: 'http://downloads.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-20160205.tar.xz', checksum: '7e97e2af042e1b6f62cf0298fe84839014ef3d4a3e7825cffc6931c66cc0fc20') }
    it { is_expected.to extract_archive_file('extract msys2 base archive to C:\\msys2\\.cache').with(destination: 'C:\\msys2\\.cache') }
    it { is_expected.to create_directory('C:\\msys2\\bin') }
    it { is_expected.to create_template('C:\\msys2\\bin\\bash.bat').with(source: 'bash.bat.erb') }
    it { is_expected.to create_template('C:\\msys2\\custom-upgrade.sh').with(source: 'custom-upgrade.sh.erb') }
    it { is_expected.to create_template('C:\\msys2\\etc\\profile.d\\custom_prefix.sh').with(source: 'custom_prefix.sh.erb') }

    it do
      is_expected.to run_execute('installing base-devel').with(
        command: '.\\bin\\bash.bat -c \'pacman -S --needed --noconfirm base-devel\'',
        cwd: 'C:\\msys2'
      )
    end
  end

  context 'installing with a custom base archive' do
    recipe do
      msys2_package 'base-devel' do
        root 'C:\\msys2'
        source_url 'https://example.test/msys2-base-x86_64.tar.xz'
        checksum 'abc123'
      end
    end

    it { is_expected.to create_remote_file('cache msys2 base to C:\\msys2\\.cache').with(source: 'https://example.test/msys2-base-x86_64.tar.xz', checksum: 'abc123') }
  end

  context 'removing a package' do
    recipe do
      msys2_package 'base-devel' do
        root 'C:\\msys2'
        action :remove
      end
    end

    it { is_expected.to run_execute('removing base-devel') }
  end
end
