# frozen_string_literal: true

property :root, String, required: true,
                        callbacks: { 'must be a dedicated directory, not a filesystem root' => ->(path) { !path.empty? && path !~ %r{\A(?:[A-Za-z]:[\\/]?|[\\/]+)\z} } }
