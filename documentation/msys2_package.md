# msys2_package

Installs, upgrades or removes an MSYS2 package or package group. Provides
`msys2_package`. Required `root` is the shared MSYS2 directory; `package` defaults
to the resource name. Set `url` and `checksum` together for a custom base archive.

The default base is the verified official x64 stable 2026-09-27 tar.zst archive.
Native extraction strips its msys64 wrapper directory. Existing roots with
pacman installed are retained. The shell shim and PREMSYS2_PATH and
PREMSYS2_PKG_CONFIG_PATH integration remain. Initial core updates restart the
login shell between passes, following the vendor update model.

`:install` skips installed packages or complete groups. `:upgrade` explicitly
requests a full rolling system update and package installation using two fresh
login shells, including for an existing installation. `:remove` removes
the named package, or the currently installed members of a package group, while preserving the shared MSYS2 installation. No missing
installation is bootstrapped during removal. Custom archives must retain the
standard msys64 top-level directory structure.
