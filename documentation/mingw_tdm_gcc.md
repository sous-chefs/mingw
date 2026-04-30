# mingw_tdm_gcc

Installs a TDM-GCC compiler toolchain on Windows. Provides a compiler only — pair with `mingw_get` (or `msys2_package`) for support tools (`make`, `grep`, `awk`, `bash`, etc.).

## Actions

- `:install` - Downloads and extracts the TDM-GCC archives at `root`. Default action.
- `:remove` - Recursively deletes the install root.

## Properties

- `flavor` - Either `:sjlj_32` or `:seh_sjlj_64`. The 64-bit flavor is a multi-lib cross-compiler that defaults to 64-bit output and uses SEH for 64-bit code; SJLJ for any 32-bit code it produces. The 32-bit flavor only builds 32-bit binaries and uses SJLJ.
- `root` - The install root. Must not contain spaces.
- `version` - The TDM-GCC version. Currently only `'5.1.0'` is supported. This is the name attribute.

## Examples

Install the 32-bit TDM-GCC compiler at `C:\mingw32`:

```ruby
mingw_tdm_gcc '5.1.0' do
  flavor :sjlj_32
  root 'C:\mingw32'
end
```

Install the 64-bit TDM-GCC compiler at `C:\mingw64`:

```ruby
mingw_tdm_gcc '5.1.0' do
  flavor :seh_sjlj_64
  root 'C:\mingw64'
end
```

Remove a TDM-GCC install (deletes the entire `root` tree):

```ruby
mingw_tdm_gcc '5.1.0' do
  root 'C:\mingw64'
  action :remove
end
```
