# frozen_string_literal: true

describe command('C:/mingw-test-msys2/mingw64/bin/gcc.exe -dumpmachine') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(/^x86_64-w64-mingw32\s*$/) }
end
describe command('C:/mingw-test-msys2/usr/bin/make.exe --version') do
  its('exit_status') { should eq 0 }
  its('stdout') { should include 'GNU Make' }
end
describe command('C:/mingw-test-msys2/hello.exe') do
  its('exit_status') { should eq 0 }
end

describe command('C:/mingw-test-msys2/usr/bin/bash.exe -lc "pacman -Q db gdbm nano"') do
  its('exit_status') { should eq 0 }
end
describe command('C:/mingw-test-msys2/usr/bin/bash.exe -lc "pacman -Q emacs"') do
  its('exit_status') { should eq 1 }
end
