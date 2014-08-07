#  General utilities or use with scripts
require 'ib-ruby'

module PryIb
  class Connection
     TWS_HOST='127.0.0.1'

     #   tws_port = 7442     # TWS live port
     #   tws_port = 7496     # TWS demo port
     #   tws_port = 4001     # gateway port
     TWS_SERVICE_PORTS={ tws_live: 7442, tws_demo: 7496, tws_gateway: 4001 }
     DEFAULT_OPTIONS = {  client_id: nil,
                           host:    TWS_HOST,
                           port:    TWS_SERVICE_PORTS[:tws_demo],
                           service: :tws_demo
      }

      @@conn = nil  # IB connection

      def self.connection(service = :tws_gateway)
        return @@conn unless @@conn.nil?
        @@conn = make_connection( :service => service )
      end

      def self.make_connection(  opts = {} )
        options = DEFAULT_OPTIONS.merge(opts)
        raise "No service opt. #{opts.inspect}" if options[:service].nil? 
        raise "No port opt. #{opts.inspect}" if options[:port].nil? 
        raise "No host opt. #{opts.inspect}" if options[:host].nil? 
        puts "> make_connection: #{opts.inspect}"

        port = TWS_SERVICE_PORTS[options[:service].to_sym]
        options[:port] = port
        if options[:service] == :tws_live
          puts "************************************"
          puts "**** GO LIVE !!!"
          puts "************************************"
          system('echo -e "\a\a"')
        end
        # Connect to IB TWS.
        new_connection( options )

        @@conn
      end

      def self.new_connection( options )
        begin
          @@conn.close if @conn
          # Connect to IB TWS.
          puts "---- Connect: #{options[:service].to_s}. options:#{options.inspect}  "
          @@conn = IB::Connection.new( client_id:  options[:client_id],  host: options[:host], port: options[:port])
        rescue => err
          puts "Failed to connect #{options[:service].to_s}. options:#{options.inspect}  Error:#{err.message} "
          raise err
        end
      end


  end
end
