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
end
