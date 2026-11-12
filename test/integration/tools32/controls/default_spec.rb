# frozen_string_literal: true

describe command('C:/mingw32/bin/gcc.exe --version') do
  its('exit_status') { should eq 0 }
  its('stdout') { should include '5.1.0' }
end
describe command('C:/mingw32/bin/gcc.exe -dumpmachine') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(/^mingw32\s*$/) }
end
describe command('C:/mingw32/msys/1.0/bin/make.exe --version') do
  its('exit_status') { should eq 0 }
  its('stdout') { should include 'GNU Make 3.81' }
end

describe command('C:/mingw32/bin/hello.exe') do
  its('exit_status') { should eq 0 }
end
