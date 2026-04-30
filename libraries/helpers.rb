# frozen_string_literal: true

require 'cgi'
require 'uri'

module Mingw
  module Helpers
    def win_friendly_path(path)
      path.gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR || '\\') if path
    end

    def archive_name(source)
      url = ::URI.parse(source)
      ::File.basename(::CGI.unescape(url.path))
    end

    def tar_name(source)
      aname = archive_name(source)
      ::File.basename(aname, ::File.extname(aname))
    end
  end
end
