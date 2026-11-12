# frozen_string_literal: true

property :root, String, required: true,
                        callbacks: { 'must be an absolute dedicated Windows directory, not a filesystem root' => ->(path) { Mingw::Helper.valid_install_root?(path) } }
