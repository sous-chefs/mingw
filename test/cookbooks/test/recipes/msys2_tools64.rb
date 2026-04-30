# frozen_string_literal: true

root_path = "#{ENV.fetch('SYSTEMDRIVE')}\\msys2"

msys2_package 'base-devel' do
  root root_path
end

msys2_package 'mingw-w64-x86_64-toolchain' do
  root root_path
end
