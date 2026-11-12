# Testing

Run `chef install Policyfile.rb`, `chef exec cookstyle` and `chef exec rspec`.
Native Windows Server2025 CI runs all four Kitchen suites with two converges:
default, tools32, tools64 and msys2. Each suite has an InSpec profile.
The default suite compiles and executes a small C program. Legacy suites inspect
TDM compiler identity/target and MSYS make. MSYS2 coverage includes package groups.

On a Windows test host, run `chef exec kitchen test default-windows-2025`.
Kitchen uses the local exec transport, so use a disposable Windows test machine.
No Windows runtime is available on the development Mac; no Parallels lab is used.
The feature branch has a scoped push trigger to obtain native Kitchen evidence
before opening a PR. Full branch and PR checks must pass before merge.
