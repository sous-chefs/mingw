# frozen_string_literal: true

require 'spec_helper'

describe 'mingw_get' do
  step_into :mingw_get
  platform 'windows', '2019'

  context 'installing a package' do
    recipe do
      mingw_get 'msys-base=2013072300-msys-bin.meta' do
        root 'C:\\mingw32'
      end
    end

    it { is_expected.to create_directory('C:\\mingw32\\.cache') }
    it { is_expected.to create_remote_file('cache mingw-get to C:\\mingw32\\.cache') }
    it { is_expected.to extract_archive_file('extract mingw-get to C:\\mingw32').with(destination: 'C:\\mingw32') }

    it do
      is_expected.to run_execute('performing install for msys-base=2013072300-msys-bin.meta').with(
        command: '.\\bin\\mingw-get.exe -v install msys-base=2013072300-msys-bin.meta',
        cwd: 'C:\\mingw32'
      )
    end
  end

  context 'removing a package' do
    recipe do
      mingw_get 'msys-base=2013072300-msys-bin.meta' do
        root 'C:\\mingw32'
        action :remove
      end
    end

    it { is_expected.to run_execute('performing remove for msys-base=2013072300-msys-bin.meta') }
  end
end
