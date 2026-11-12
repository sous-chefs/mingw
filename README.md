# mingw cookbook

Installs Windows compiler tools through MSYS2, MinGW-get and TDM-GCC.
Supports Windows with Chef/Cinc 18+. MSYS2 requires x64 Windows 10 or Server 2016+.
Use native custom resources in a wrapper cookbook; no setup recipe is required.

```ruby
msys2_package 'mingw-w64-x86_64-gcc' do
  root 'C:/msys64'
end
```

## Resources

* [mingw_get](documentation/mingw_get.md): MinGW package install, upgrade, remove.
* [mingw_tdm_gcc](documentation/mingw_tdm_gcc.md): TDM 5.1.0,32-bit SJLJ or64-bit SEH/SJLJ.
* [msys2_package](documentation/msys2_package.md): current MSYS2 packages and groups.

Use MSYS2 for current toolchains. TDM 5.1.0 and MinGW-get remain for compatibility
with software that needs those compiler/runtime conventions. They are legacy
versions, not equivalent to the current MSYS2 toolchain.

See [migration to 5.0](migration.md) for removed recipes/attributes and source settings.
See [testing](TESTING.md) for native Windows acceptance.

Licensed under Apache-2.0. Original author: Chef Software, Inc.; maintained by Sous Chefs.
