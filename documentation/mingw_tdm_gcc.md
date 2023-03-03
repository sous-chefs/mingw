# mingw_tdm_gcc

## Actions

- `:install` - Installs the TDM compiler toolchain at the given path. This only gives you a compiler. If you need any support tooling such as make/grep/awk/bash etc., see `mingw_get`.

## Parameters

- `flavor` - Either `:sjlj_32` or `:seh_sjlj_64`. TDM-64 is a 32/64-bit multi-lib "cross-compiler" toolchain that builds 64-bit by default. It uses structured exception handling (SEH) in 64-bit code and setjump-longjump exception handling (SJLJ) in 32-bit code. TDM-32 only builds 32-bit binaries and uses SJLJ.
- `root` - The root directory where compiler tools and runtime will be installed. This directory must not contain any spaces in order to pacify old posix tools and most Makefiles.
- `version` - The version of the compiler to fetch and install. This is the name attribute. Currently, '5.1.0' is supported.

## Examples

To get the 32-bit TDM GCC compiler in `C:\mingw32`

```ruby
mingw_tdm_gcc '5.1.0' do
  flavor :sjlj_32
  root 'C:\mingw32'
end
```
