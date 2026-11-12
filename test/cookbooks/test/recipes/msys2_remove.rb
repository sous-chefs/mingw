# frozen_string_literal: true

msys2_package 'tree' do
  root 'C:/mingw-test-msys2'
  action :remove
end

msys2_package 'editors' do
  root 'C:/mingw-test-msys2'
  action :remove
end
