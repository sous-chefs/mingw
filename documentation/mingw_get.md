# mingw_get

## Actions

- `:install` - Installs a mingw package from sourceforge using mingw-get.exe.
- `:remove` - Uninstalls a mingw package.
- `:upgrade` - Upgrades a mingw package (even to a lower version).

## Parameters

- `package` - A mingw-get package (or meta-package) to fetch and install. You may use a legal package wild-card pattern here if you are installing. This is the name attribute.
- `root` - The root directory where msys and mingw tools will be installed. This directory must not contain any spaces in order to pacify old posix tools and most Makefiles.

## Examples

To get the core msys developer tools in `C:\mingw32`

```ruby
mingw_get 'msys-base=2013072300-msys-bin.meta' do
  root 'C:\mingw32'
end
```
