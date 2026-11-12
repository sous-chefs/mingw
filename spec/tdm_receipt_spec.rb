# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require_relative '../libraries/tdm_receipt'

describe Mingw::TDMReceipt do
  if File::ALT_SEPARATOR == '\\'
    let(:runner) do
      lambda do |*command, **options|
        result = Mixlib::ShellOut.new(*command, **options)
        result.run_command
        result.error!
        result
      end
    end

    def allow_untrusted_modify(runner, path)
      script = <<~'POWERSHELL'
        $ErrorActionPreference = 'Stop'
        $acl = Get-Acl -LiteralPath $env:CHEF_MINGW_TEST_ACL
        $users = [Security.Principal.SecurityIdentifier]::new('S-1-5-32-545')
        $rule = [Security.AccessControl.FileSystemAccessRule]::new($users, 'Modify', 'Allow')
        $acl.AddAccessRule($rule)
        Set-Acl -LiteralPath $env:CHEF_MINGW_TEST_ACL -AclObject $acl
      POWERSHELL
      runner.call(Mingw::TDMReceipt.powershell, '-NoProfile', '-NonInteractive', '-EncodedCommand',
                  Base64.strict_encode64(script.encode('UTF-16LE')),
                  environment: { 'CHEF_MINGW_TEST_ACL' => path })
    end

    it 'rejects an existing writable receipt instead of securing and trusting its contents' do
      described_class.audit!(runner, 'ensure')
      Dir.mktmpdir('mingw-receipt-acl') do |root|
        receipt = described_class.path(root, '5.1.0', :seh_sjlj_64)
        begin
          File.write(receipt, '{}')
          described_class.audit!(runner, 'receipt', receipt: receipt)
          allow_untrusted_modify(runner, receipt)
          expect { described_class.audit!(runner, 'receipt', receipt: receipt) }
            .to raise_error(Mixlib::ShellOut::ShellCommandFailed, %r{Untrusted write/delete permissions})
        ensure
          File.delete(receipt) if File.exist?(receipt)
        end
      end
    end

    it 'refuses automatic removal from a user-writable root without deleting user data' do
      Dir.mktmpdir('mingw-root-acl') do |root|
        sentinel = File.join(root, 'unrelated.txt')
        File.write(sentinel, 'keep')
        allow_untrusted_modify(runner, root)
        expect { described_class.audit!(runner, 'tree', root: root) }
          .to raise_error(Mixlib::ShellOut::ShellCommandFailed, %r{Untrusted write/delete permissions})
        expect(File.read(sentinel)).to eq('keep')
      end
    end
  end
end
