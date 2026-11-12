# MinGW cookbook migration

## Scope and product

Owner explicitly chose full custom-resource migration and a major release.
Remove root recipes/attributes and seven_zip; preserve mingw_get,
mingw_tdm_gcc (TDM 5.1.0, both flavours) and msys2_package APIs.
Owner approved refreshing the MSYS2 default while retaining custom URL/checksum.
Never use the Parallels lab. Native hosted Windows is the integration environment.

## Vendor research

* [MSYS2 installer formats](https://www.msys2.org/docs/installer/): official
  tar.zst base plus a first login shell provides the archive installation.
* [Windows support](https://www.msys2.org/docs/windows_support/): current packages
  require x64 Windows 10/Server 2016+, GUI installer Server 2019+. This cookbook
  extracts an archive, not the GUI installer. Hosted test uses Server 2025.
* [Pinned stable base](https://github.com/msys2/msys2-installer/releases/tag/2026-09-27):
  tar.zst SHA256 8a2095647afbf799d113d0cae35f7544589d059819042635504e75bd2179bd02
  verified from the official GitHub release asset digest. Avoid the moving
  releases/latest endpoint: it currently points to nightly-x86_64.
* [TDM project](https://jmeubank.github.io/tdm-gcc/download/): newer10.3 exists,
  but updating compiler/runtime ABI is outside this behaviour-preserving migration.
  Preserve the original5.1.0 archive checksums and32-bit patched headers.
* [Chef archive_file](https://docs.chef.io/client/19/resources/bundled/archive_file/)
  uses libarchive; replace the prior two-stage7Zip extraction with direct native
  archive extraction. Native Windows acceptance must prove tar.lzma and tar.zst.

## Implementation contracts

Package removal retains shared MinGW/MSYS2 bootstrap installations. TDM removal
requires its own completed installation marker and a dedicated root. Root recipes
and node attributes disappear in5.0.0; settings become resource properties.
No source compilation is needed to install the supplied toolchains. Tests compile
and run a small C program to verify toolchain behaviour.

MinGW upstream source cloned read-only in /private/tmp/mingw-get-source.
src/pkgshow.cpp prints Installed Version: none for missing components and a
canonical archive name for installed ones; list/show share DisplayPackageInfo in
src/climain.cpp. Guards inspect all returned components and requested constraints.
MSYS2 guards query both ordinary packages and every group member. Explicit upgrade
still requests a rolling system update; regular install must be idempotent.

## CI and acceptance

Policyfile-first. Windows-only: remove unrelated Linux/Dokken/Mac matrices.
Keep current org reusable workflows9.0.1, not the older skill example6.0.0.
Use the previously verified official Cinc PowerShell installer and its actual
cinc-project/cinc-workstation path. Native hosted Kitchen with two converges and
InSpec is mandatory before merge. No local Windows runtime is available and the
owner expressly requested hosted testing. Push the feature branch (with its scoped push trigger) to obtain that
runtime evidence before invoking the PR publication skill; do not claim acceptance from local ChefSpec alone.

## Local verification before branch publication

Policyfile resolves;11 ChefSpec examples pass; Cookstyle25 files clean.
Workflow actionlint, YAML and Markdown checks pass. Kitchen lists exactly
default/tools32/tools64/msys2 on windows-2025. Root recipes and attributes are
absent; three resources use explicit provides/unified_mode/frozen headers.
Native Windows install, second converge and removal remain unverified until
the scoped branch-push CI run completes. No PR before that evidence.


## First native branch run

CI43227324920: default5 assertions, second0/14. MSYS2 group suite5 assertions,
second0/26; package-removal phase7 assertions, second0/2. Both TDM suites
extracted native tar.lzma and installed components but failed second-converge
idempotence on aggregate msys-base. Upstream pkgshow.cpp deliberately omits
Installed Version for whole packages and emits Components instead. Guards now
query every explicit component, with a virtual-package regression case.

Lifecycle config is standalone via KITCHEN_YAML, because Kitchen deep-merges
inspec_tests arrays from local overrides; TDM removal must not inherit assertions
that the removed compiler exists. Root validation canonicalises dot segments
before rejecting drive roots or UNC shares; absolute subdirectories are required.
