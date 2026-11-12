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
