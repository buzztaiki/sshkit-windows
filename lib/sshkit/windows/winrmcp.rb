# -*- coding: utf-8 -*-

require 'base64'

module SSHKit

  module Windows
    # SSHKit::Windows::WinRMCP provides file transfer features using WinRM
    class WinRMCP
      def initialize(winrm)
        @winrm = winrm
      end

      # based on VagrantWindows::Communication::WinRMShell
      # TODO:
      # - file existence check
      # - recursive
      # - progress
      def upload(from, to, options={}, &progress)
        tmp = mktemp
        to = join_path(to, File.basename(from)) if directory?(to)

        powershell("if(Test-Path '#{to}') {rm '#{to}'}")
        Base64.encode64(IO.binread(from)).gsub("\n",'').chars.to_a.each_slice(8000) do |chunk|
          powershell("echo '#{chunk.join}' >> '#{tmp}'")
        end

        dname = dirname(to)
        powershell <<-EOH
if (-Not (Test-Path '#{dname}')) {
  mkdir '#{dname}'
}
$base64_string = Get-Content '#{tmp}'
$bytes = [System.Convert]::FromBase64String($base64_string)
$new_file = [System.IO.Path]::GetFullPath('#{to}')
[System.IO.File]::WriteAllBytes($new_file,$bytes)
EOH
      end

      # based on VagrantWindows::Communication::WinRMShell
      # TODO:
      # - file existence check
      # - recursive
      # - progress
      def download(from, to, options={}, &progress)
        to = File.join(to, basename(from)) if File.directory?(to)
        output = @winrm.powershell("[System.convert]::ToBase64String([System.IO.File]::ReadAllBytes('#{from}'))")
        contents = output[:data].map{|line| line[:stdout]}.join.gsub("\\n\\r", '')
        out = Base64.decode64(contents)
        IO.binwrite(to, out)
      end

      private

      def full_stdout(output)
        output[:data].map{|line| line[:stdout]}.join
      end

      def powershell(script)
        output = @winrm.powershell(script)
        full_stdout(output).chomp
      end

      def directory?(path)
        powershell("Test-Path '#{path}' -PathType Container") == 'True'
      end

      def dirname(path)
        powershell("$([System.IO.Path]::GetDirectoryName('#{path}'))")
      end

      def basename(path)
        powershell("$([System.IO.Path]::GetFileName('#{path}'))")
      end

      def join_path(dir, file)
        powershell("$([System.IO.Path]::Combine('#{dir}', '#{file}'))")
      end

      def mktemp
        powershell("$([System.IO.Path]::GetTempFileName())")
      end
    end
  end
end
