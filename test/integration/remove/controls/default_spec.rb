# frozen_string_literal: true

describe directory('C:/mingw64') do
  it { should_not exist }
end
