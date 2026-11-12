# mingw_tdm_gcc

Installs the retained TDM-GCC 5.1.0 compiler. Provides `mingw_tdm_gcc`.

Required `root` is an absolute Windows directory and may share MinGW/MSYS packages.
`version` defaults to the resource name and accepts 5.1.0. `flavor` accepts
`:sjlj_32` or `:seh_sjlj_64` (default). The 32-bit flavour retains MinGW runtime
dependencies and original pthread/time header patches. Archive checksums are unchanged.

`:install` records completion only after all components succeed and skips archive
extraction on later converges. Its JSON ownership manifest records only files and
directories newly created by the TDM extraction/header phase, after shared package
dependencies are installed. Pre-existing paths are never adopted for deletion.

`:remove` deletes only recorded files whose SHA256 still matches and removes only
empty directories created by this installation. It preserves pre-existing files,
shared MinGW/MSYS packages, files added later and modified files. It never
recursively deletes the root. The root itself is removed only if this resource
created it and it is now empty. Use the same version/flavour for removal.

Removal refuses unrecognised manifests, changed root identity and symlink/junction
redirection. Initial installation through a symlink can complete, but automated
removal through that root is unsupported and fails safely. Files from an older
untracked installation remain unowned and require separate review for removal.
Device namespaces, DOS device names, dot segments and trailing-dot/space path
components are rejected as install roots.
