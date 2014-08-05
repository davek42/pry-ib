#  General utilities or use with scripts
module PryIb
  class Connection
     #   tws_host = '10.0.1.3'  # cleopatra
     #   tws_port = 7496     # TWS demo port
     #   tws_port = 4001     # gateway port
#      TWS_HOST='10.0.1.2'
      TWS_HOST='127.0.0.1'
#      TWS_HOST='10.0.1.57'
      TWS_SERVICE_PORTS={ tws_live: 7442, tws_demo: 7496, tws_gateway: 4001 }
      DEFAULT_OPTIONS = {  client_id: nil,
                           host: TWS_HOST,
                           port: TWS_SERVICE_PORTS[:tws_demo],
                           service_name: :tws_demo
      }

      def self.connection(service = :tws_gateway)
        return @@conn unless @@conn.nil?
        @@conn = make_connection( :service => :tws_gateway )
      end

      def self.make_connection(  opts = {} )
        options = DEFAULT_OPTIONS.merge(opts)
        port =  options[:port]

        if not options[:service].nil? 
            port = TWS_SERVICE_PORTS[options[:service_name].to_sym]
            if options[:service] == :tws_live
              puts "************************************"
              puts "**** GO LIVE !!!"
              puts "************************************"
              system('echo -e "\a\a"')
            end
        end
        # Connect to IB TWS.
        puts "---- Connect: #{options[:service].to_s}. options:#{options.inspect}  port: #{port}"
        ib = IB::Connection.new( client_id:  options[:client_id], port: port, host: options[:host] )

        ib
      end
    
  end
end
