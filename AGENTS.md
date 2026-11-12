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


## Independent review corrections

Review found Windows trailing-dot/space paths and device namespaces bypassed
POSIX cleanpath checks. Reject those components, DOS device names and device
namespaces before filesystem mutation. Pure helper regressions also run natively
on Windows; they do not create or remove any test path.

Preserve the old batch shim environment in direct bash calls: HOME uses the Ruby
expanded Windows username; MSYS2_PATH_TYPE=minimal, CHERE_INVOKING=1, MSYSTEM=MSYS.
Existing-root upgrades use two fresh login shells, per
[MSYS2 update guidance](https://www.msys2.org/docs/updating/). Install completeness
queries remote group membership; removal independently queries locally installed
members, so partial groups are removable without installing missing members.
Native coverage uses the real Database group and partial editors group (nano
present, emacs absent), then removes installed editors while retaining MSYS2.

Second run43229491781 proved TDM64 C++ compilation/execution (7 assertions) and
second0/28, plus actual removal and second0/2. Its verify failed because
kitchen-inspec always adds test/integration/SUITE to explicit profiles. YAML
verifier test_base_path is ignored by Kitchen. Source and local diagnose confirm
CLI --test-base-path test selects only explicit lifecycle profiles. TDM32 compile
failed exit1 with empty output; restore the original test PATH (toolchain bin plus
MSYS bin) for compiler child programs, and include -v diagnostics. No compiler
version, runtime archive or flavour is changed.

The added upgrade suite seeds an existing pinned archive then calls :upgrade;
its action deliberately refreshes the system, so that new suite runs once and
asserts no outstanding updates. All four install suites and two remove phases
continue to enforce two converges and a zero-change second converge.

Pacman upstream src/pacman/query.c returns1 when no package matches -Qu.
The upgrade profile expects exit1 with empty stdout/stderr, distinguishing no
updates from a query error. Local SDK inspection confirms the lifecycle CLI
--test-base-path override; YAML alone cannot override this setting.

Reviewed follow-up local verification:16 ChefSpec examples pass and Cookstyle29
files clean. Actual Kitchen loader with CLI test_base_path=test reports zero
implicit lifecycle profiles and exactly the requested removal profile per suite.


## Shared-root ownership correction

The original proposed new TDM remove action recursively deleted a marked root.
Review correctly rejected it: mingw_get deliberately shares that root, and files
may predate install or be added/modified later. TDM now snapshots names after
shared dependencies, records only newly created artifacts with SHA256 and root
realpath/device/inode/link identity, and uses individual guarded file deletes plus
nonrecursive empty-directory removal. Pre-existing and modified files remain.
Unrecognised metadata or redirected roots/parents fail before any deletion plan.
No recursive root deletion remains. Native helper tests create only their own
Tempdir files/junctions, and native lifecycle preserves before/after sentinels,
shared MSYS make and a user-built executable while deleting owned compiler files.

Third run43233451179: default, existing-root upgrade and TDM64 lifecycle passed.
MSYS partial editors removal correctly refused to break base dependency on nano;
fixture now uses only Vulkan headers from a six-member optional UCRT Vulkan group,
leaving loader absent, then removes that partial group without dependency bypass.
The Database group tests complete-group installation. TDM32 verbose compilation
gets through cc1plus and reaches its assembler, then exits1. Local PE inspection
of the official binutils2.25.1 archive shows libiconv-2.dll as its only non-system
import. Fixture restores the exact backslash PATH and working-directory convention
for Windows DLL loading; failure-only diagnostics report assembler exit and DLL
machine type. No speculative compiler/runtime replacement is made.

## File-protection workflow bootstrap

The audited reusable9.0.1 caller uses prevent-file-change v3, which requires
pull_request_target for untrusted actors. Its transitively audited action at
440fe0989b54093ce834a504af595ee55967da4d uses GitHub APIs only: no PR checkout,
execution or shell interpolation. Caller events are opened/reopened/synchronize;
PR-write permission is scoped to that job. The default-branch target workflow
bootstraps after this feature merges. Require an actual target-event guard run on
the generated major release before release merge/publication; a trusted-actor
legacy fast path is not proof of the new event contract.

Audit pointers rechecked: reusable9.0.1 tag resolves to
3cdff8f6f62b3db50db18f41b2de281297e355d3; v3 annotated tag resolves to
440fe0989b54093ce834a504af595ee55967da4d with node24 dist/index.js entrypoint.
Final ownership follow-up local checks:20 RSpec pass, Cookstyle31 clean,
Markdown/YAML/actionlint clean. Native ownership regressions and fresh lifecycle
acceptance must still pass before PR publication or merge.
