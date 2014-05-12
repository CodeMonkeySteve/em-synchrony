begin
  require "moped/connection"
rescue LoadError => error
  raise "Missing EM-Synchrony dependency: gem install moped"
end

# monkey-patch Moped to use em-synchrony's socket
silence_warnings do
  module Moped
    class EM_TCP < EventMachine::Synchrony::TCPSocket
      include defined?(Moped::Sockets) ? Moped::Sockets::Connectable : Moped::Connection::Socket::Connectable

      def self.connect(*args)
        host, port, timeout = args
        begin
          super
        rescue SocketError => ex
          raise Errors::ConnectionFailure, "#{host}:#{port}: #{ex.class.name}: #{ex.message}"
        end
      end

      def set_encoding(enc)
        raise "Can't set socket encoding to #{enc.inspect}"  unless %w(binary ascii-8bit).include?(enc.downcase)
      end

      def alive?
        !error?
      end
    end

    class Connection
      def connect
        raise "SSL not supported"  if !!options[:ssl]
        @sock = Moped::EM_TCP.connect(host, port, timeout)
      end
    end
  end
end
