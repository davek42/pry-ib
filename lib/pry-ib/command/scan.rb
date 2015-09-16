
module PryIb
  module Command
    module Scan
      def self.build(commands)

        commands.create_command "scan" do
          description "Run scanneer"
          group 'pry-ib'
          def options(opt)
            opt.on :num=, 'Number of rows (Default 20)'
            opt.on :above=, 'Price above (Default 10)'
            opt.on :vol=, 'Volume above (Default 10000)'
          end

          def process
            ib = PryIb::Connection::current

            num_rows = (opts.num?) ? opts[:num].to_i : 20
            above = (opts.above?) ? opts[:above].to_f  : 10.0
            volume = (opts.vol?) ? opts[:volume].to_i  : 10000
            parms = { 
              num_rows: num_rows, 
              scan_code: 'TOP_PERC_GAIN', 
              above_price: above, 
              location_code: 'STK.US.MAJOR', 
              above_volume: volume, 
            }
            scanner = PryIb::Scanner.new(ib)
            scanner.scan(parms)
          end
        end

      end
    end
  end
end
