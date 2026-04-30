# frozen_string_literal: true

root_path = "#{ENV.fetch('SYSTEMDRIVE')}\\mingw32"

mingw_get 'msys core - 32 bit' do
  package 'msys-base=2013072300-msys-bin.meta'
  root root_path
end

mingw_get 'msys core extensions - 32 bit' do
  package 'msys-coreutils-ext=5.97-3-*'
  root root_path
end

mingw_get 'msys perl - 32 bit' do
  package 'msys-perl-bin=5.8.8-*'
  root root_path
end

mingw_tdm_gcc '5.1.0' do
  flavor :sjlj_32
  root root_path
end
