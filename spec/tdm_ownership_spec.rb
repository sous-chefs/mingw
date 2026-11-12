# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require 'fileutils'
require_relative '../libraries/tdm_ownership'

describe Mingw::TDMOwnership do
  def redirect_directory(link, target)
    if File::ALT_SEPARATOR == '\\'
      success = system('cmd', '/c', 'mklink', '/J', link.tr('/', '\\'), target.tr('/', '\\'), out: File::NULL, err: File::NULL)
      raise 'Could not create the test-owned junction' unless success
    else
      File.symlink(target, link)
    end
  end

  it 'owns only newly created files, preserving pre-existing paths and later changes' do
    Dir.mktmpdir('mingw-ownership') do |root|
      File.write(File.join(root, 'existing.txt'), 'before')
      before = described_class.inventory(root)
      FileUtils.mkdir_p(File.join(root, 'bin'))
      File.write(File.join(root, 'bin/compiler.exe'), 'compiler')
      File.write(File.join(root, 'existing.txt'), 'updated by install')
      manifest = described_class.build(root, before, false)
      expect(manifest['files'].keys).to eq(['bin/compiler.exe'])
      expect(described_class.plan(root, manifest)[:files]).to eq(['bin/compiler.exe'])

      File.write(File.join(root, 'added-later.txt'), 'user data')
      File.write(File.join(root, 'bin/compiler.exe'), 'user modification')
      expect(described_class.plan(root, manifest)[:files]).to be_empty
      expect(File.read(File.join(root, 'existing.txt'))).to eq('updated by install')
      expect(File.read(File.join(root, 'added-later.txt'))).to eq('user data')
    end
  end

  it 'refuses a root replaced with a symlink or Windows junction' do
    Dir.mktmpdir('mingw-ownership') do |base|
      root = File.join(base, 'root')
      moved = File.join(base, 'moved')
      Dir.mkdir(root)
      before = described_class.inventory(root)
      File.write(File.join(root, 'compiler.exe'), 'compiler')
      manifest = described_class.build(root, before, true)
      File.rename(root, moved)
      redirect_directory(root, moved)
      expect { described_class.plan(root, manifest) }.to raise_error(ArgumentError, /identity changed|symlink/)
      expect(File.read(File.join(moved, 'compiler.exe'))).to eq('compiler')
    end
  end

  it 'refuses redirected intermediate directories before planning any deletion' do
    Dir.mktmpdir('mingw-ownership') do |base|
      root = File.join(base, 'root')
      target = File.join(base, 'other')
      Dir.mkdir(root)
      Dir.mkdir(target)
      File.write(File.join(target, 'sentinel.txt'), 'keep')
      before = described_class.inventory(root)
      FileUtils.mkdir_p(File.join(root, 'bin'))
      File.write(File.join(root, 'bin/compiler.exe'), 'compiler')
      manifest = described_class.build(root, before, true)
      File.rename(File.join(root, 'bin'), File.join(base, 'original-bin'))
      redirect_directory(File.join(root, 'bin'), target)
      expect { described_class.plan(root, manifest) }.to raise_error(ArgumentError, /Redirected|escaped/)
      expect(File.read(File.join(target, 'sentinel.txt'))).to eq('keep')
    end
  end

  it 'rejects unrecognised manifests and paths outside the managed directory' do
    Dir.mktmpdir('mingw-ownership') do |root|
      expect { described_class.plan(root, {}) }.to raise_error(ArgumentError, /Unrecognised/)
      manifest = described_class.build(root, described_class.inventory(root), false)
      manifest['files']['../other.txt'] = 'a' * 64
      expect { described_class.plan(root, manifest) }.to raise_error(ArgumentError, /Invalid TDM ownership path/)
    end
  end
end
