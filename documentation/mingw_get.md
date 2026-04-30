# mingw_get

Manages legacy MinGW packages from SourceForge using `mingw-get.exe`. Prefer `msys2_package` for new installs; `mingw_get` exists for compatibility with legacy toolchains and is required by `mingw_tdm_gcc` in 32-bit mode.

## Actions

- `:install` - Installs the named mingw-get package. Default action.
- `:remove` - Uninstalls the named mingw-get package.
- `:upgrade` - Upgrades the named mingw-get package (may downgrade).

## Properties

- `package` - A mingw-get package or meta-package. Wildcards are accepted. This is the name attribute.
- `root` - The directory where MinGW/MSYS will be installed. Must not contain spaces.
- `source_url` - URL to the `mingw-get` archive. Defaults to the SourceForge mirror that the cookbook ships with.
- `checksum` - SHA-256 checksum of the `mingw-get` archive.

## Examples

Install the core MSYS developer tools at `C:\mingw32`:

```ruby
mingw_get 'msys-base=2013072300-msys-bin.meta' do
  root 'C:\mingw32'
end
```
