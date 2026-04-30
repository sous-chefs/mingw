# Limitations

## Package Availability

This cookbook manages Windows toolchains. It does not use APT, DNF/YUM, or Zypper package repositories.

### MSYS2

* MSYS2 pre-built packages currently require 64-bit Windows 10 or Windows Server 2016 or later.
* The MSYS2 GUI installer currently requires 64-bit Windows 10 1809 or Windows Server 2019 or later.
* MSYS2 still publishes `x86_64` base archives from `https://repo.msys2.org/distrib/x86_64/`.
* 32-bit Windows MSYS2 archives are no longer actively supported.
* The `MINGW32` and `MINGW64` environments can still target Windows 7 and later, but running current MSYS2 packages requires a newer host OS.

### MinGW and TDM-GCC

* `mingw_get` and `mingw_tdm_gcc` install legacy SourceForge-hosted archives.
* TDM-GCC 5.1.0 artifacts are from 2015 and should be treated as legacy compatibility tooling.
* The cookbook only supports the TDM-GCC archive checksums already encoded in the resource.

## Architecture Limitations

* The MSYS2 default base archive used by this cookbook is `x86_64`.
* `msys2_package` package names decide whether 32-bit or 64-bit MinGW packages are installed inside the MSYS2 root.
* `mingw_tdm_gcc` supports the existing `:sjlj_32` and `:seh_sjlj_64` flavors only.

## Source/Compiled Installation

This cookbook installs pre-built toolchain archives and packages. It does not build MinGW, MSYS2, or TDM-GCC from source.

## Known Issues

* Windows Server 2012 R2 is no longer a suitable default test target. Microsoft regular support ended on October 10, 2023, and MSYS2 dropped active support for Windows 8.1 / Windows Server 2012 R2 on February 28, 2026.
* `mingw_get` and `mingw_tdm_gcc` rely on old SourceForge URLs. They remain for compatibility but MSYS2 should be preferred for new installs.
