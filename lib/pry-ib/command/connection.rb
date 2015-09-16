
module PryIb
  module Command
    module Connection
      def self.build(commands)
        # connection
        commands.create_command "connection" do
          description "connection -- manage IB client connection"
          group 'pry-ib'
          def setup
            @service = nil
          end

          def set_prompt(name="")
            #Pry.config.prompt = proc { |obj, nest_level, _| "IB(#{name}: #{obj}(#{nest_level})> " }
            _pry_.prompt = proc { |obj, nest_level, _| "IB(#{name}): #{obj}(#{nest_level})> " }
          end

          def options(opt)
            opt.on :s, :show, "show services"
            opt.on :c, :close, "close current connection"
            opt.on :r, :reconnect, "reconnect connection"
            opt.on :o, :host, "host"
            opt.on :b, :subs, "subscribers"
            opt.on :u, :unsub=, "unsubscribe id"
            opt.on :service=, 'set Service name'
            opt.on :l, :live, "use Live Service"
            opt.on :t, :test,  "use Test Service"
            opt.on :g,:gateway, "use Gateway Service"
          end

          def process
            if opts.show?
              output.puts "Current Service:#{ PryIb::Connection::service} "
              output.puts "Current connection client_id: #{PryIb::Connection::current.client_id}"
              PryIb::Connection::SERVICE_PORTS.each do |key, val|
                current = (key == PryIb::Connection::service) ? "(Active)" : ""
                output.puts "Service: #{key} Port:#{val}  #{current}"
              end
              return
            end
            if opts.host?
              output.puts "--->"
              output.puts "Host: #{PryIb::Connection::host}"
              return
            end
            if opts.close?
              output.puts "--->"
              output.puts "Close: #{PryIb::Connection::service}"
              set_prompt ""
              PryIb::Connection::close
              return
            end
            if opts.reconnect?
              output.puts "--->"
              output.puts "Reconnect: #{PryIb::Connection::service}"
              set_prompt "reconnecting"
              PryIb::Connection::reconnect
              set_prompt "#{PryIb::Connection::current_name}"
              return
            end

            if opts.subs?
              output.puts "--->"
              PryIb::Connection::subscribers
              return
            end
            if opts.unsub?
              @unsub_id = opts[:unsub].to_i
              output.puts "Unsuscribe #{@unsub_id}"
              PryIb::Connection::unsubscribe @unsub_id
              return
            end

            # make new service connection
            if opts.service?
              @service = opts[:service].to_sym
              output.puts "Set service: #{@service}"
            elsif opts.live?
              output.puts "Live service "
              @service = :ib_live
              set_prompt "#{PryIb::Connection::current_name(@service)}"
            elsif opts.test? || opts.test?
              @service = :ib_test
              set_prompt "#{PryIb::Connection::current_name(@service)}"
            elsif opts.gateway?
              @service = :ib_gateway
              set_prompt "#{PryIb::Connection::current_name(@service)}"
            end

            if @service
              #output.puts "Set service: #{@service}"
              return PryIb::Connection::connection( @service )
            end

            # return current connection
            ib = PryIb::Connection::current
            if ib
              output.puts "Use current connection"
            else
              output.puts "No current connection"
            end
            return ib 
          end
        end
      end
    end
  end
end
