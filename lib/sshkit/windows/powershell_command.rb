# -*- coding: utf-8 -*-
module SSHKit
  module Windows
    class PowerShellCommand < Command
      def path(value)
        value.gsub('/', '\\')
      end

      def within(&block)
        return yield unless options[:in]
        "Set-Location \"#{options[:in]}\" -ErrorAction Stop; %s" % path(yield)
      end

      def environment_string
        environment_hash.collect do |key,value|
          "$env:#{key.to_s.upcase}=\"#{value}\""
        end.join(';')
      end

      def with(&block)
        return yield unless environment_hash.any?
        "#{environment_string}; %s" % yield
      end

      def in_background(&block)
        return yield unless options[:run_in_background]
        "Start-Job -Init ([ScriptBlock]::Create(\"Set-Location $pwd\")) -Script {%s}" % yield
      end

      def to_command
        return command.to_s unless should_map?
        within do
          with do
            in_background do
              to_s
            end
          end
        end
      end

      def to_s
        [(should_map? ? path(command.to_s) : command) , *Array(args)].join(' ')
      end
    end
  end
end
