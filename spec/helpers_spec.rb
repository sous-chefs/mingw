# frozen_string_literal: true

require 'spec_helper'
require_relative '../libraries/_helper'

describe Mingw::Helper do
  subject(:helper) { Object.new.extend(described_class) }

  it 'decodes URL paths with the current URI API' do
    expect(helper.archive_name('https://example.test/a%2Bb.tar.lzma')).to eq('a+b.tar.lzma')
  end

  it 'recognises all installed components' do
    expect(helper.mingw_installed_output?("Installed Version: binutils-2.25.1-1-mingw32-bin.tar.xz\n", '2.25.1-*')).to be true
    expect(helper.mingw_installed_output?("Installed Version: none\n")).to be false
    expect(helper.mingw_installed_output?("Installed Version: installed\nInstalled Version: none\n")).to be false
    expect(helper.mingw_installed_output?('unknown package')).to be false
  end

  it 'does not treat another installed version as the requested version' do
    expect(helper.mingw_installed_output?("Installed Version: gcc-6.3.0-1-mingw32-bin.tar.xz\n", '5.1.0-*')).to be false
  end

  it 'checks virtual package component state instead of reinstalling aggregates' do
    allow(helper).to receive(:new_resource).and_return(double(root: 'C:/mingw', package: 'msys-base=2013072300-msys-bin.meta'))
    allow(File).to receive(:exist?).with('C:/mingw/bin/mingw-get.exe').and_return(true)
    allow(helper).to receive(:shell_out).with('"C:/mingw/bin/mingw-get.exe" show msys-base')
                                        .and_return(double(exitstatus: 0, stdout: "Components: bin\n"))
    allow(helper).to receive(:shell_out).with('"C:/mingw/bin/mingw-get.exe" show msys-base-bin')
                                        .and_return(double(exitstatus: 0, stdout: "Installed Version: msys-base-2013072300-msys-bin.meta\n"))
    expect(helper.mingw_package_installed?).to be true
  end

  it 'rejects canonical drive roots and relative paths before any install or removal' do
    ['C:/', 'C:/tools/..', 'C:\\tools\\..', '.', '../tools', '//server/share', 'C:/ ', 'C:/foo/.. ', '//server/share/. ',
     '//?/GLOBALROOT/Device/HarddiskVolume1', '//./C:/tools', 'C:/NUL', 'C:/foo:bar'].each do |path|
      expect(described_class.valid_install_root?(path)).to be false
    end
    ['C:/tools', 'C:\\tools', '//server/share/tools'].each do |path|
      expect(described_class.valid_install_root?(path)).to be true
    end
  end
end
