# msys2_package

- ':install' - Installs an msys2 package using pacman.
- ':remove' - Uninstalls any existing msys2 package.
- ':upgrade' - Upgrades the specified package using pacman.

All options also automatically attempt to install a 64-bit based msys2 base file system at the root path specified. Note that you probably won't need a "32-bit" msys2 unless you are actually on a 32-bit only platform. You can still install both 32 and 64-bit compilers and libraries in a 64-bit msys2 base file system.

## Attributes

- `node['msys2']['url']` - overrides the url from which to download the package.
- `node['msys2']['checksum']` - overrides the checksum used to verify the downloaded package.

## Parameters

- `package` - An msys2 pacman package (or meta-package) to fetch and install. You may use a legal package wild-card pattern here if you are installing. This is the name attribute.
- `root` - The root directory where msys2 tools will be installed. This directory must not contain any spaces in order to pacify old posix tools and most Makefiles.

## Examples

To get the core msys2 developer tools in `C:\msys2`

```ruby
msys2_package 'base-devel' do
  root 'C:\msys2'
end
```
