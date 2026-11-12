# frozen_string_literal: true

require 'base64'
require 'digest'

module Mingw
  module TDMReceipt
    def self.directory
      ::File.join(ENV.fetch('ProgramData', 'C:/ProgramData'), 'sous-chefs-mingw')
    end

    def self.path(root, version, flavor)
      key = "#{::File.expand_path(root).tr('\\', '/').downcase}|#{version}|#{flavor}"
      ::File.join(directory, "#{Digest::SHA256.hexdigest(key)}.json")
    end

    def self.assert_path!(receipt)
      parent = ::File.expand_path(::File.dirname(receipt)).tr('\\', '/').downcase
      expected = ::File.expand_path(directory).tr('\\', '/').downcase
      unless parent == expected && ::File.basename(receipt).match?(/\A[0-9a-f]{64}\.json\z/)
        raise ArgumentError, 'Untrusted TDM receipt location; refusing removal'
      end
    end

    def self.script
      <<~'POWERSHELL'
      $ErrorActionPreference = 'Stop'
      try {
        $trusted = @('S-1-5-18', 'S-1-5-32-544')
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal]::new($identity)
        if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
          $trusted += $identity.User.Value
        }
        try {
          $installer = [Security.Principal.NTAccount]::new('NT SERVICE', 'TrustedInstaller')
          $trusted += $installer.Translate([Security.Principal.SecurityIdentifier]).Value
        } catch { }
        $seen = @{}
        $ancestorMask = 0x10000 -bor 0x40000 -bor 0x80000 -bor 0x40
        $strictMask = $ancestorMask -bor 2 -bor 4 -bor 16 -bor 256
        function Assert-TrustedPath([string]$path, [bool]$strict) {
          $full = [IO.Path]::GetFullPath($path)
          if ($seen.ContainsKey($full) -and ($seen[$full] -or !$strict)) { return }
          $item = Get-Item -LiteralPath $full -Force
          if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            throw "Reparse point is not trusted for TDM removal: $full"
          }
          $acl = Get-Acl -LiteralPath $full
          $owner = $acl.GetOwner([Security.Principal.SecurityIdentifier]).Value
          if ($trusted -notcontains $owner) { throw "Untrusted TDM path owner: $full" }
          $mask = if ($strict) { $strictMask } else { $ancestorMask }
          foreach ($rule in $acl.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier])) {
            if ($rule.AccessControlType -ne [Security.AccessControl.AccessControlType]::Allow) { continue }
            if ($rule.PropagationFlags -band [Security.AccessControl.PropagationFlags]::InheritOnly) { continue }
            $sid = $rule.IdentityReference.Value
            if (($trusted -notcontains $sid) -and ($sid -ne 'S-1-3-4') -and
                (([long]$rule.FileSystemRights -band $mask) -ne 0)) {
              throw "Untrusted write/delete permissions on TDM path: $full"
            }
          }
          $seen[$full] = $strict
          $parent = if ($item.PSIsContainer) { $item.Parent } else { $item.Directory }
          if ($parent) { Assert-TrustedPath $parent.FullName $false }
        }
        function Assert-TrustedTree([string]$root) {
          Assert-TrustedPath $root $true
          $pending = New-Object 'Collections.Generic.Stack[string]'
          $pending.Push($root)
          while ($pending.Count -gt 0) {
            $current = $pending.Pop()
            foreach ($entry in Get-ChildItem -LiteralPath $current -Force) {
              Assert-TrustedPath $entry.FullName $true
              if ($entry.PSIsContainer) { $pending.Push($entry.FullName) }
            }
          }
        }
        $state = $env:CHEF_MINGW_STATE
        $mode = $env:CHEF_MINGW_TRUST_MODE
        if ($mode -eq 'ensure') {
          if (!(Test-Path -LiteralPath $state)) {
            Assert-TrustedPath ([IO.Directory]::GetParent($state).FullName) $false
            $security = New-Object Security.AccessControl.DirectorySecurity
            $security.SetSecurityDescriptorSddlForm('O:BAG:BAD:P(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)')
            [IO.Directory]::CreateDirectory($state, $security) | Out-Null
          }
          # Existing untrusted directories are never repaired/adopted as trusted.
          Assert-TrustedPath $state $true
        } elseif ($mode -eq 'tree') {
          Assert-TrustedTree $env:CHEF_MINGW_ROOT
        } else {
          Assert-TrustedPath $state $true
          Assert-TrustedPath $env:CHEF_MINGW_RECEIPT $true
          if ($mode -eq 'removal') {
            # No untrusted writer may swap a path between a check and deletion.
            Assert-TrustedTree $env:CHEF_MINGW_ROOT
          }
        }
      } catch {
        [Console]::Error.WriteLine($_.Exception.Message)
        exit 1
      }
      POWERSHELL
    end

    def self.powershell
      ::File.join(ENV.fetch('SystemRoot', 'C:/Windows'), 'System32/WindowsPowerShell/v1.0/powershell.exe').tr('/', '\\')
    end

    def self.audit!(runner, mode, root: nil, receipt: nil)
      assert_path!(receipt) if receipt
      encoded = Base64.strict_encode64(script.encode('UTF-16LE'))
      runner.call(powershell, '-NoProfile', '-NonInteractive', '-EncodedCommand', encoded,
                  environment: { 'CHEF_MINGW_STATE' => directory, 'CHEF_MINGW_TRUST_MODE' => mode,
                                 'CHEF_MINGW_ROOT' => root.to_s, 'CHEF_MINGW_RECEIPT' => receipt.to_s,
                                 'PSModulePath' => ::File.join(ENV.fetch('SystemRoot', 'C:/Windows'), 'System32/WindowsPowerShell/v1.0/Modules') })
    end
  end
end
