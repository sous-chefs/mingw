# frozen_string_literal: true

describe command('C:/mingw-test-upgrade/usr/bin/bash.exe -lc "pacman -Qu"') do
  # pacman returns1 when no installed package matches the upgrade filter.
  its('exit_status') { should eq 1 }
  its('stderr') { should eq '' }
  its('stdout') { should eq '' }
end
describe command('C:/mingw-test-upgrade/usr/bin/make.exe --version') do
  its('exit_status') { should eq 0 }
end
