require 'spec_helper'

set :path, "C:\\mingw32\\bin;C:\\mingw32\\msys\\1.0\\bin;#{ENV['PATH']}"

describe command("gcc -v") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain 'Target: mingw32' }
  its(:stdout) { should contain 'gcc version 5.1.0 (tdm-1)' }
end

describe command("make --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain 'GNU Make 3.81' }
end

