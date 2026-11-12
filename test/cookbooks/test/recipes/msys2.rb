# frozen_string_literal: true

include_recipe 'test::default'
msys2_package 'base-devel' do
  root 'C:/mingw-test-msys2'
end

msys2_package 'tree' do
  root 'C:/mingw-test-msys2'
end

%w(Database nano).each do |name|
  msys2_package name do
    root 'C:/mingw-test-msys2'
  end
end
