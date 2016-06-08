module Ey
  module Core
    module Cli
      module Helpers
        module StreamPrinter

          def stream_print(opts)
            yield Printer.new(opts)
          end

          class Printer
            def initialize(rows = {})
              @rows = rows
            end
            def print(*vals)
              unless @header_printed
                header = []
                separator = []
                @rows.each do |k,v|
                  header << format(k, v)
                  separator << '-' * v
                end
                puts header.join("| ")
                puts separator.join("|-")
                @header_printed = true
              end
              line = []
              vals.each_with_index do |v,index|
                line << format(v, @rows.values[index])
              end
              puts line.join("| ")
            end
            def format(value, width)
              TablePrint::FixedWidthFormatter.new(width).format(value)
            end
          end

        end
      end
    end
  end
end
