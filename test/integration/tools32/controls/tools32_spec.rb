# frozen_string_literal: true

title '32-bit TDM-GCC Toolchain'

control 'mingw-tools32-01' do
  impact 1.0
  title '32-bit compiler is installed'

  describe file('C:\\mingw32\\bin\\gcc.exe') do
    it { should exist }
  end

  describe command('C:\\mingw32\\bin\\gcc.exe -dumpmachine') do
    its('stdout') { should cmp "mingw32\n" }
    its('exit_status') { should eq 0 }
  end
end

control 'mingw-tools32-02' do
  impact 1.0
  title '32-bit support tools are installed'

  describe command('C:\\mingw32\\bin\\as.exe --version') do
    its('stdout') { should include '2.25.1' }
    its('stdout') { should include 'mingw32' }
    its('exit_status') { should eq 0 }
  end

  describe command('C:\\mingw32\\msys\\1.0\\bin\\make.exe --version') do
    its('stdout') { should include 'GNU Make 3.81' }
    its('exit_status') { should eq 0 }
  end
end
