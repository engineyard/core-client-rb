module Ey
  module Core
    module Cli
      module Helpers
        module LogStreaming

          def stream_deploy_log(request)
            if request.finished_at
              return finished_request(request)
            end
            unless request.read_channel
              puts "Unable to stream log (streaming not enabled for this deploy)".yellow
              return
            end
            request.subscribe { |m| print m["message"] if m.is_a?(Hash) }
            puts "" # fix console output from stream
            finished_request(request)
          end

          def finished_request(request)
            if request.successful
              if request.resource.successful
                puts "Deploy successful!".green
              else
                puts "Deploy failed!".red
              end
            else
              abort <<-EOF
        Deploy failed!
        Request output:
        #{request.message}
              EOF
              .red
            end
          end

        end
      end
    end
  end
end
