# mingw_tdm_gcc

Installs the retained TDM-GCC 5.1.0 compiler. Provides `mingw_tdm_gcc`.

Required `root` must be dedicated to this toolchain. `version` defaults to the
resource name and accepts5.1.0. `flavor` accepts `:sjlj_32` or `:seh_sjlj_64`
(default). The32-bit flavour retains MinGW runtime dependencies and the original
pthread/time header patches. Original compiler archive checksums are unchanged.

`:install` records completion only after all components succeed and then skips
archive extraction on subsequent converges. `:remove` removes the dedicated root
only if its completed installation marker exists. Unmarked roots are retained.

Use the same version and flavour when removing an installation. A completion
marker for another flavour is not treated as ownership of the requested one.
Roots must be absolute dedicated Windows directories. Device namespaces, DOS
device names, dot segments and trailing-dot/space path components are rejected.
