# msys2_package

Manages MSYS2 packages on Windows. The first call against a given `root` bootstraps the MSYS2 base file system at that path; subsequent calls reuse it.

## Actions

- `:install` - Installs the named MSYS2 package via `pacman -S --needed --noconfirm`. Default action.
- `:remove` - Uninstalls the named MSYS2 package via `pacman -R --noconfirm`.
- `:upgrade` - Upgrades the named MSYS2 package (and all dependencies — pacman) via `pacman -Syu --noconfirm`.

All actions automatically install the 64-bit MSYS2 base file system at `root` if it is not already present. You will not normally need a 32-bit MSYS2 base; you can still install both 32-bit and 64-bit compilers and libraries from inside a 64-bit base.

## Properties

- `package` - The pacman package (or meta-package) name. Wildcards are accepted by pacman. This is the name attribute.
- `root` - The directory where the MSYS2 base file system lives (and where `pacman` runs). Must not contain spaces.
- `source_url` - URL to the MSYS2 base archive. Defaults to the SourceForge `msys2-base-x86_64-20160205.tar.xz` mirror that the cookbook ships with.
- `checksum` - SHA-256 checksum of the base archive. Must match `source_url`.

## Examples

Install the `base-devel` meta-package using the bundled MSYS2 base archive:

```ruby
msys2_package 'base-devel' do
  root 'C:\msys2'
end
```

Pin the cookbook to a custom MSYS2 base archive:

```ruby
msys2_package 'base-devel' do
  root 'C:\msys2'
  source_url 'https://example.test/msys2-base-x86_64.tar.xz'
  checksum 'abc123...'
end
```

Remove a package:

```ruby
msys2_package 'base-devel' do
  root 'C:\msys2'
  action :remove
end
```
