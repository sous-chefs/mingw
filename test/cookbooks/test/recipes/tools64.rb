# frozen_string_literal: true

root_path = "#{ENV['SYSTEMDRIVE']}\\mingw64"

mingw_get 'msys core - 64 bit' do
  package 'msys-base=2013072300-msys-bin.meta'
  root root_path
end

mingw_get 'msys core extensions - 64 bit' do
  package 'msys-coreutils-ext=5.97-3-*'
  root root_path
end

mingw_get 'msys perl - 64 bit' do
  package 'msys-perl-bin=5.8.8-*'
  root root_path
end

mingw_tdm_gcc 'TDM GCC - 64 bit' do
  version '5.1.0'
  flavor :seh_sjlj_64
  root root_path
end

file "#{root_path}/hello.cpp" do
  content "int main() { try { throw 42; } catch (int value) { return value == 42 ? 0 : 1; } }\n"
end
execute 'compile TDM C++ exception test' do
  command "\"#{root_path}/bin/g++.exe\" -v \"#{root_path}/hello.cpp\" -o \"#{root_path}/bin/hello.exe\""
  environment('PATH' => "#{root_path}/bin;#{root_path}/msys/1.0/bin;#{ENV['PATH']}")
  creates "#{root_path}/bin/hello.exe"
end
