# mingw_get

Installs, upgrades or removes a MinGW package. Provides `mingw_get`.

Required `root` is the shared MinGW directory. `package` defaults to the resource
name and accepts the existing MinGW version/wildcard expression. `source` and
`checksum` control the verified MinGW-get bootstrap ZIP; the legacy 0.6.2 default
is retained with HTTPS. Native `archive_file` extracts it without seven_zip.

`:install` skips matching installed components; `:upgrade` explicitly requests an
upgrade. `:remove` does not bootstrap an absent installation and preserves shared
package-manager files. Invalid shell metacharacters in package names are rejected.
