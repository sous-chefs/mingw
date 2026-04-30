# frozen_string_literal: true

title '64-bit TDM-GCC Toolchain'

control 'mingw-tools64-01' do
  impact 1.0
  title '64-bit compiler is installed'

  describe file('C:\\mingw64\\bin\\gcc.exe') do
    it { should exist }
  end

  describe command('C:\\mingw64\\bin\\gcc.exe -dumpmachine') do
    its('stdout') { should cmp "x86_64-w64-mingw32\n" }
    its('exit_status') { should eq 0 }
  end
end

control 'mingw-tools64-02' do
  impact 1.0
  title '64-bit support tools are installed'

  describe command('C:\\mingw64\\bin\\as.exe --version') do
    its('stdout') { should include 'x86_64-w64-mingw32' }
    its('exit_status') { should eq 0 }
  end

  describe command('C:\\mingw64\\msys\\1.0\\bin\\make.exe --version') do
    its('stdout') { should include 'GNU Make 3.81' }
    its('exit_status') { should eq 0 }
  end
end
