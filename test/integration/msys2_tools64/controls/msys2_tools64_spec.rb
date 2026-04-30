# frozen_string_literal: true

title '64-bit MSYS2 Toolchain'

control 'mingw-msys2-tools64-01' do
  impact 1.0
  title '64-bit MSYS2 compiler is installed'

  describe file('C:\\msys2\\mingw64\\bin\\gcc.exe') do
    it { should exist }
  end

  describe command('cmd.exe /c "set MSYSTEM=MINGW64&& C:\\msys2\\bin\\bash.bat -lc \"/mingw64/bin/gcc -dumpmachine\""') do
    its('stdout') { should cmp "x86_64-w64-mingw32\n" }
    its('exit_status') { should eq 0 }
  end
end

control 'mingw-msys2-tools64-02' do
  impact 1.0
  title '64-bit MSYS2 compiler can build binaries'

  describe command('cmd.exe /c "set MSYSTEM=MINGW64&& C:\\msys2\\bin\\bash.bat -lc \"echo int main(){} | /mingw64/bin/gcc -xc -o test.exe -\""') do
    its('exit_status') { should eq 0 }
  end
end
