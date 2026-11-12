# frozen_string_literal: true

name 'mingw'
run_list 'test::default'
cookbook 'mingw', path: '.'
cookbook 'test', path: './test/cookbooks/test'

%w(default tools32 tools64 msys2 remove msys2_remove upgrade).each do |suite|
  named_run_list suite.to_sym, "test::#{suite}"
end
