# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../libraries/helpers'

describe Mingw::Helpers do
  let(:helper) { Class.new { include Mingw::Helpers }.new }

  describe '#win_friendly_path' do
    it 'converts separators to Windows separators' do
      expect(helper.win_friendly_path('C:/msys2/bin')).to eq('C:\\msys2\\bin')
    end
  end

  describe '#archive_name' do
    it 'decodes escaped archive paths' do
      expect(helper.archive_name('https://example.test/GCC%205%20series/archive.tar.lzma')).to eq('archive.tar.lzma')
    end
  end

  describe '#tar_name' do
    it 'removes the outer archive extension' do
      expect(helper.tar_name('https://example.test/archive.tar.lzma')).to eq('archive.tar')
    end
  end
end
