# Migration Guide

## What Changed

`mingw` is now a custom-resource-only cookbook. The `mingw::default` recipe and `node['msys2']` attributes have been removed.

## Recipe Migration

Before:

```ruby
include_recipe 'mingw::default'

msys2_package 'base-devel' do
  root 'C:\msys2'
end
```

After:

```ruby
msys2_package 'base-devel' do
  root 'C:\msys2'
end
```

Archive extraction now uses Chef Infra Client's built-in `archive_file` resource.

## Attribute Migration

Before:

```ruby
default['msys2']['url'] = 'https://example.test/msys2-base.tar.xz'
default['msys2']['checksum'] = 'abc123'
```

After:

```ruby
msys2_package 'base-devel' do
  root 'C:\msys2'
  source_url 'https://example.test/msys2-base.tar.xz'
  checksum 'abc123'
end
```

## Test Cookbook Examples

The migration examples live in `test/cookbooks/test/recipes/`:

* `default.rb` installs the default MSYS2 workflow.
* `msys2_tools64.rb` installs the MSYS2 64-bit toolchain.
* `tools32.rb` installs the legacy 32-bit TDM-GCC workflow.
* `tools64.rb` installs the legacy 64-bit TDM-GCC workflow.
