# frozen_string_literal: true

root = 'C:/mingw-test-msys2'
%w(mingw-w64-x86_64-gcc make).each do |name|
  msys2_package name do
    root root
  end
end

file "#{root}/hello.c" do
  content "int main(void) { return 0; }\n"
end
execute 'compile native test program' do
  command "\"#{root}/mingw64/bin/gcc.exe\" \"#{root}/hello.c\" -o \"#{root}/hello.exe\""
  creates "#{root}/hello.exe"
end
