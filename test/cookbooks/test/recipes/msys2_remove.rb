# frozen_string_literal: true

msys2_package 'tree' do
  root 'C:/mingw-test-msys2'
  action :remove
end

msys2_package 'mingw-w64-ucrt-x86_64-vulkan-devel' do
  root 'C:/mingw-test-msys2'
  action :remove
end
