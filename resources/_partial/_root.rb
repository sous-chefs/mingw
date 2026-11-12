# frozen_string_literal: true

property :root, String, required: true,
                        callbacks: { 'must be an absolute Windows directory, not a filesystem root' => ->(path) { Mingw::Helper.valid_install_root?(path) } }
