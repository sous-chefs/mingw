# frozen_string_literal: true

title 'Default MSYS2 Installation'

control 'mingw-msys2-default-01' do
  impact 1.0
  title 'MSYS2 base is installed'

  describe file('C:\\msys2\\msys2.exe') do
    it { should exist }
  end

  describe file('C:\\msys2\\bin\\bash.bat') do
    it { should exist }
  end
end

control 'mingw-msys2-default-02' do
  impact 1.0
  title 'base-devel is installed'

  describe command('cmd.exe /c "set MSYSTEM=MSYS&& C:\\msys2\\bin\\bash.bat -lc \"pacman -Q base-devel\""') do
    its('exit_status') { should eq 0 }
  end
end
