# frozen_string_literal: true

describe file('C:/mingw-test-msys2/usr/bin/pacman.exe') do
  it { should exist }
end
describe command('C:/mingw-test-msys2/usr/bin/bash.exe -lc "pacman -Q tree"') do
  its('exit_status') { should eq 1 }
end
