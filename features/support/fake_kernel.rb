require 'aruba/processes/in_process'

module Aruba
  module Processes
    class InProcess < BasicProcess
      attr_reader :kernel

      class FakeKernel
        def system(*args)
          system_commands.push(args.join(' '))
        end

        def system_commands
          @system_commands ||= []
        end

        def abort(msg)
          exit(false)
        end
      end
    end
  end
end
