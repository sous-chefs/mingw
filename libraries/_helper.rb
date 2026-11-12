# frozen_string_literal: true

require 'uri'
require 'pathname'

#
# Cookbook:: mingw
# Library:: _helper
#
# Copyright:: 2016-2019, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Mingw
  module Helper
    def self.valid_install_root?(path)
      normal = Pathname.new(path.tr('\\', '/')).cleanpath.to_s
      normal.match?(%r{\A[A-Za-z]:/.+}) ||
        (path.start_with?('\\\\', '//') && normal.split('/').reject(&:empty?).size > 2)
    end

    def win_friendly_path(path)
      path.gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR || '\\') if path
    end

    def archive_name(source)
      url = ::URI.parse(source)
      ::File.basename(URI::DEFAULT_PARSER.unescape(url.path))
    end

    def tar_name(source)
      aname = archive_name(source)
      ::File.basename(aname, ::File.extname(aname))
    end

    def mingw_installed_output?(output, constraint = nil)
      versions = output.scan(/^Installed Version:\s+([^\r\n]+)/).flatten.map(&:strip)
      !versions.empty? && versions.all? do |installed|
        installed != 'none' && (!constraint || ::File.fnmatch?("*-#{constraint}*", installed))
      end
    end

    def mingw_package_installed?
      return false unless ::File.exist?(::File.join(new_resource.root, 'bin/mingw-get.exe'))

      package_name, constraint = new_resource.package.split('=', 2)
      result = shell_out("\"#{::File.join(new_resource.root, 'bin/mingw-get.exe')}\" show #{package_name}")
      return false unless result.exitstatus.zero?
      return mingw_installed_output?(result.stdout, constraint) if result.stdout.match?(/^Installed Version:/)

      # Whole-package queries enumerate components but omit installation state.
      # Query each component, including virtual .meta packages such as msys-base.
      components = result.stdout[/^Components:\s*([^\r\n]+)/, 1].to_s.split(',').map(&:strip)
      !components.empty? && components.all? do |component|
        next false unless component.match?(/\A[\w.+-]+\z/)

        state = shell_out("\"#{::File.join(new_resource.root, 'bin/mingw-get.exe')}\" show #{package_name}-#{component}")
        state.exitstatus.zero? && mingw_installed_output?(state.stdout, constraint)
      end
    end
  end
end
