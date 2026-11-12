# frozen_string_literal: true

%w(gcc.exe g++.exe).each do |name|
  describe file("C:/mingw64/bin/#{name}") do
    it { should_not exist }
  end
end
%w(keep-before.txt keep-after.txt bin/hello.exe msys/1.0/bin/make.exe).each do |name|
  describe file("C:/mingw64/#{name}") do
    it { should exist }
  end
end
describe file('C:/mingw64/keep-before.txt') do
  its('content') { should eq 'pre-existing user file' }
end
