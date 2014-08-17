#  General utilities or use with scripts
require 'ib-ruby'

module PryIb
  class Connection
     @@host='127.0.0.1'

     #   tws_port = 7442     # TWS live port
     #   tws_port = 7496     # TWS demo/test port
     #   tws_port = 4001     # gateway port
     SERVICE_PORTS={ tws_live: 7442, tws_test: 7496, tws_gateway: 4001 }
     DEFAULT_OPTIONS = {  client_id: nil,
                           host:    @@host,
                           port:    SERVICE_PORTS[:tws_test],
                           service: :tws_test
      }

      @@conn = nil  # IB connection
      @@service = nil

      def self.setup
        Pry.config.ib_host ||= '127.0.0.1'
        Pry.config.ib_live_port ||= 7442
        Pry.config.ib_test_port ||= 7496
        Pry.config.ib_gateway_port ||= 4001

        @@host = Pry.config.ib_host 
        SERVICE_PORTS[:tws_live] = Pry.config.ib_live_port 
        SERVICE_PORTS[:tws_test] = Pry.config.ib_test_port 
        SERVICE_PORTS[:tws_gateway] = Pry.config.ib_gateway_port 
        #log "Service Ports: #{SERVICE_PORTS.inspect}"
      end

      def self.service
        @@service
      end

      def self.current
        connection(@@service)
      end

      def self.connection(service)
        return @@conn unless @@conn.nil?
        @@conn = make_connection( :service => service )
      end

      def self.make_connection(  opts = {} )
        options = DEFAULT_OPTIONS.merge(opts)
        raise "No service opt. #{opts.inspect}" if options[:service].nil? 
        raise "No port opt. #{opts.inspect}" if options[:port].nil? 
        raise "No host opt. #{opts.inspect}" if options[:host].nil? 
        #log "> make_connection: #{opts.inspect}"

        @@service = options[:service].to_sym
        port = SERVICE_PORTS[@@service]
        options[:port] = port
        
        if options[:service] == :tws_live
          log "************************************"
          log "**** GO LIVE !!!"
          log "************************************"
          system('echo -e "\a\a"')
        end
        # Connect to IB TWS.
        new_connection( options )

        @@conn
      end

      def self.new_connection( options )
        begin
          @@conn.close if @@conn
          # Connect to IB TWS.
          log "---- Connect: #{options[:service].to_s}. options:#{options.inspect}  "
          @@conn = IB::Connection.new( client_id:  options[:client_id],  host: options[:host], port: options[:port])
        rescue => err
          log "Failed to connect #{options[:service].to_s}. options:#{options.inspect}  Error:#{err.message} "
          raise err
        end
      end

      def self.close
        if @@conn
          @@conn.close 
          @@conn = nil
          @@service = nil
        end

      end

      def self.subscribers
       if @@conn.nil?
        log "No connection. No subscribers"
        return
       end
       log "Conn:" % @@conn.class.name
       @@conn.subscribers.each do |sub|
         log "Sub: #{sub.inspect}"
       end
      end

      def self.unsubscribe(id)
       if @@conn.nil?
        log "No connection. No subscribers"
        return
       end
       removed = @@conn.unsubscribe id
       log "UnSub: #{removed.inspect}"
      end


  end
end
