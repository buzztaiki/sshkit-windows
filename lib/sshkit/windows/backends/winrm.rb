require 'winrm'

module SSHKit
  module Windows
    module Backend
      class WinRM < SSHKit::Backend::Printer
        def run
          instance_exec(host, &@block)
        end

        def within(directory, &block)
          (@pwd ||= []).push directory.to_s
          yield
        ensure
          @pwd.pop
        end

        def as(who, &block)
          yield
        end

        # def make(commands=[])
        #   raise MethodUnavailableError
        # end

        # def rake(commands=[])
        #   raise MethodUnavailableError
        # end

        def test(*args)
          options = args.extract_options!.merge(
            raise_on_non_zero_exit: false,
            verbosity: Logger::DEBUG
            )
          _execute(*[*args, options]).success?
        end

        def execute(*args)
          _execute(*args).success?
        end

        def background(*args)
          options = args.extract_options!.merge(run_in_background: true)
          _execute(*[*args, options]).success?
        end

        def capture(*args)
          options = args.extract_options!.merge(verbosity: Logger::DEBUG)
          _execute(*[*args, options]).full_stdout.strip
        end

        private

        def _execute(*args)
          command(*args).tap do |cmd|
            output << cmd
            cmd.started = true
            winrm.powershell(cmd.to_command) do |stdout, stderr|
              stdout ||= ''
              stderr ||= ''

              cmd.stdout = stdout
              cmd.stderr = stderr
              cmd.full_stdout << stdout
              cmd.full_stderr << stderr

              output << cmd
            end
          end
        end

        def winrm
          @winrm ||= ::WinRM::WinRMWebService.new(
            endpoint,
            :plaintext,
            user: host.username,
            pass: host.password,
            basic_auth_only: true)
        end

        def endpoint
          port = host.port || 5985
          "http://#{host.hostname}:#{port}/wsman"
        end

        def command(*args)
          options = args.extract_options!
          SSHKit::Windows::PowerShellCommand.new(*[*args, options.merge({in: @pwd.nil? ? nil : File.join(@pwd), env: @env, host: @host, user: @user, group: @group})])
        end
      end
    end
  end
end
