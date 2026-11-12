# Migrating to 5.0

The default recipe, node attributes and seven_zip dependency are removed.
Resources install their own prerequisites. Require Chef/Cinc 18 or newer.

Remove `include_recipe 'mingw::default'`; call `mingw_get`, `mingw_tdm_gcc`
or `msys2_package` directly. Their package/root/flavour interfaces remain.
TDM remains5.1.0 with32-bit SJLJ and64-bit SEH/SJLJ support; the patched32-bit
headers are retained. This release does not change compiler ABI defaults.

Replace `node['msys2']['url']` and `node['msys2']['checksum']` with
`url` and `checksum` properties on every MSYS2 package resource sharing a root.
The default is now the verified stable 2026-09-27 x64 base. Existing MSYS2 roots
are retained and not overwritten. Explicit `:upgrade` updates the rolling system;
ordinary `:install` skips already-installed packages or complete package groups.
Current MSYS2 packages require x64 Windows 10 or Windows Server 2016+.

```ruby
msys2_package 'mingw-w64-x86_64-gcc' do
  root 'C:/msys64'
end

mingw_tdm_gcc '5.1.0' do
  root 'C:/tdm64'
  flavor :seh_sjlj_64
end
```

Package `:remove` removes the requested package (or installed group members) and
retains shared bootstrap installations. TDM `:remove` uses a per-created-file
ownership manifest: pre-existing paths, modified files, shared packages and files
added later are retained. Only unchanged owned files and empty owned directories
are removed. Whole-root recursive deletion is never used. Redirected paths and
unrecognised ownership fail safely. Older installations are not silently adopted
for deletion. See [TDM resource documentation](documentation/mingw_tdm_gcc.md).
