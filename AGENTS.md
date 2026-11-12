# MinGW migration contract

## Owner decisions

Full custom-resource migration and major5.0.0 release. Remove root recipes,
attributes, Berkshelf and seven_zip. Preserve mingw_get, mingw_tdm_gcc and
msys2_package public interfaces, TDM5.1.0 flavours and patched32-bit headers.
Owner approved refreshing MSYS2 to a current verified stable base, retaining
custom URL/checksum. No Parallels lab. Use branch-triggered native Windows Kitchen
before invoking the PR skill; no PR/merge without native acceptance and review.

## Product research

* [MSYS2 installer](https://www.msys2.org/docs/installer/): tar.zst archive and
  initial login provide the archive installation. No local source compilation.
* [Windows support](https://www.msys2.org/docs/windows_support/): packages need
  x64 Windows10/Server2016+. Native CI uses Server2025, not stale Linux/Mac matrices.
* Stable2026-09-27 archive, not moving latest/nightly:
  [official release](https://github.com/msys2/msys2-installer/releases/tag/2026-09-27).
  SHA2568a2095647afbf799d113d0cae35f7544589d059819042635504e75bd2179bd02
  verified against official release asset digest.
* [MSYS2 update model](https://www.msys2.org/docs/updating/): two fresh shells when
  core changes. Fresh bootstrap and existing-root upgrade both implement this.
* TDM remains5.1.0 intentionally; do not replace compiler/runtime ABI speculatively.
  [TDM project](https://jmeubank.github.io/tdm-gcc/download/).
* [Chef archive_file](https://docs.chef.io/client/19/resources/bundled/archive_file/)
  replaces two-stage seven_zip extraction using native libarchive.

## Resource behaviour

MinGW show/list aggregate queries emit Components but omit Installed Version;
query each component. Confirmed from upstream pkgshow.cpp, pkginst.cpp and official
msys-base catalogue. Sources cloned read-only at /private/tmp/mingw-get-source.
Version constraints and virtual .meta package state must remain idempotent.

MSYS2 keeps the batch shim and prefix integration, including expanded Windows
username HOME, minimal PATH, MSYSTEM and CHERE_INVOKING. Install checks ordinary
packages and complete remote groups. Remove uses local installed group members,
retaining shared bootstrap data and respecting pacman dependency checks.

## Trusted TDM deletion ownership

Never recursively delete a TDM root. Shared MinGW/MSYS roots are supported.
Snapshot names after shared dependencies; own only newly created TDM files and
empty directories, fingerprinting file contents. Pre-existing, modified and later
added files remain. Changed root realpath/file ID, links and redirected parents
fail before a deletion plan. Invalid Windows root forms are rejected.

Root-local receipts are untrusted and rejected. State lives under ProgramData in
sous-chefs-mingw, keyed by root/version/flavour hash. Static Windows PowerShell5.1
uses an absolute OS executable, no profiles and system-only module path. It creates
state atomically with an explicit SYSTEM/Admin ACL using the .NET Framework
Directory.CreateDirectory(path, DirectorySecurity) overload. Existing untrusted
state is refused, never repaired then adopted. Receipts have protected ACLs and
Admin ownership. All relevant owners, ACLs, ancestors and reparse points are
checked before use/removal; untrusted mutation/delete/ownership rights are refused.

Only a root trusted before and after install receives deletion ownership. An
installation can complete in a mutable shared root, but its protected receipt
records removal_supported=false; later ACL repair does not silently adopt old
files. Unsupported/changed/unverifiable ownership means no automatic removal.
Initial symlink-root installation can complete but automated removal is refused.
The current elevated administrator SID, SYSTEM/Admin group and Windows trusted
installer are trusted principals; other ownership/permissions fail conservatively.
No ACLs of caller-managed roots are silently repaired.

Native regressions use test-owned Tempdirs/junctions and receipt files only. They
cover forged root-local receipt rejection, writable receipt/root refusal,
pre-existing/modified files, and redirected roots/parents. Fixture roots are
isolated C:/mingw-test-tdm32 and64, secured before bootstrap. Never reuse GitHub's
preinstalled C:/mingw64. Lifecycle must retain before/after sentinels, shared MSYS
make and user-built executable while deleting unchanged owned compiler files.

## CI evidence and remaining gates

Local21 RSpec pass before native-only ACL examples; Cookstyle, YAML, Markdown and
workflow checks are required. Four install suites and two removal phases retain
two converges and strict idempotence. Added existing-root upgrade explicitly
refreshes the system once and verifies no pending updates; pacman query.c returns1
when -Qu matches nothing, so require exit1 plus empty stdout/stderr.

Prior runs proved current MSYS2 install/groups/removal, existing-root core upgrade,
TDM64 C++ execution and idempotence. TDM32 compilation reaches as.exe then exits1;
local official binutils2.25.1 PE import inspection identifies libiconv-2.dll.
Use exact native backslash PATH/bin working directory and capture assembler exit,
DLL machine type on failure. No compiler/runtime version replacement is authorised.

Kitchen-inspec automatically adds test/integration/SUITE even with explicit
profiles; YAML test_base_path is ignored. Actual SDK inspection proved lifecycle
CLI --test-base-path test selects only explicit removal profiles.

## Protection workflow bootstrap

Audited reusable9.0.1 resolves3cdff8f6f62b3db50db18f41b2de281297e355d3.
Its v3 action resolves440fe0989b54093ce834a504af595ee55967da4d: API-only, no PR
checkout/execution or shell text interpolation. Caller uses pull_request_target
opened/reopened/synchronize and job-scoped PRwrite. This bootstraps on default
branch after feature merge. Require a real target-event guard run on the generated
major release before publication. Trusted-actor legacy fast paths are not proof.

Native addf1d0 run43247629281 reached13 helper examples. Production protected
state creation and original receipt ACL audit passed. The two refusal tests
failed only in their setup mutation helper: inherited pwsh7 PSModulePath could
not load its Security module in Windows PowerShell5.1. Test subprocess now uses
the same system-only module path as production. No trust checks were relaxed.
