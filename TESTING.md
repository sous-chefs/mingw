# Testing

Run `chef install Policyfile.rb`, `chef exec cookstyle` and `chef exec rspec`.
Native Windows Server2025 CI runs all four install Kitchen suites with two converges:
default, tools32, tools64 and msys2. Each suite has an InSpec profile.
The default suite compiles and executes a small C program. Legacy suites inspect
TDM compiler identity/target and MSYS make. MSYS2 coverage includes complete and partial package groups. A fifth suite seeds
an existing MSYS2 root and explicitly upgrades it, then checks that no updates
remain. That explicit upgrade action runs once because it deliberately requests
a system refresh; the four install suites and both removal phases retain two
converges with strict idempotence. Windows also runs non-destructive path/helper
regressions before Kitchen.

On a Windows test host, run `chef exec kitchen test default-windows-2025`.
Kitchen uses the local exec transport, so use a disposable Windows test machine.
No Windows runtime is available on the development Mac; no Parallels lab is used.
The feature branch has a scoped push trigger to obtain native Kitchen evidence
before opening a PR. Full branch and PR checks must pass before merge.
