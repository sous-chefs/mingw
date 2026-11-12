# frozen_string_literal: true

require 'spec_helper'
require_relative '../libraries/msys2_helper'

describe Mingw::MSYS2Helper do
  subject(:helper) { Object.new.extend(described_class) }
  before do
    allow(helper).to receive(:new_resource).and_return(double(root: 'C:/msys2', package: 'editors'))
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('C:/msys2/usr/bin/pacman.exe').and_return(true)
    allow(helper).to receive(:shell_out).with(helper.bash_command('pacman -Q -- editors'), environment: helper.msys_environment)
                                        .and_return(double(exitstatus: 1, stdout: ''))
  end

  it 'installs an incomplete group but removes its currently installed members' do
    allow(helper).to receive(:shell_out).with(helper.bash_command('pacman -Sgq -- editors'), environment: helper.msys_environment)
                                        .and_return(double(exitstatus: 0, stdout: "nano\nvim\nemacs\n"))
    allow(helper).to receive(:shell_out).with(helper.bash_command('pacman -Q -- nano vim emacs'), environment: helper.msys_environment)
                                        .and_return(double(exitstatus: 1, stdout: ''))
    allow(helper).to receive(:shell_out).with(helper.bash_command('pacman -Qgq -- editors'), environment: helper.msys_environment)
                                        .and_return(double(exitstatus: 0, stdout: "nano\n"))
    expect(helper.package_installed?).to be false
    expect(helper.installed_targets).to eq(['nano'])
  end
end
