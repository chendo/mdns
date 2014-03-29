require "mdns/version"
require "resolv"
require "ipaddr"

class MDNS
  MULTICAST_IP = '224.0.0.251'
  MDNS_PORT = 5353

  class Record < Struct.new(:host, :ttl, :ip); end

  class << self
    def start
      @socket = UDPSocket.new
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, true) if Socket.const_defined?("SO_REUSEPORT")
      ip_mreq = IPAddr.new(MULTICAST_IP).hton + IPAddr.new('0.0.0.0').hton
      @socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, ip_mreq)
      @socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_TTL, 255)
      @socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_MULTICAST_TTL, 255)
      @socket.bind(Socket::INADDR_ANY, MDNS_PORT)
      Thread.abort_on_exception = true
      @thr = Thread.new do
        loop do
          data = @socket.recv(1024)
          packet = begin
            Resolv::DNS::Message.decode(data)
          rescue Resolv::DNS::DecodeError
          end
          next if packet.nil?
          if packet.qr == 0
            hosts = packet.question.map(&:first).map(&:to_s)
            matches = self.hosts & hosts
            matches.each do |host|
              respond(records[host])
            end
          end
        end
      end

      # Broadcast records
      records.values.each do |record|
        respond(record)
      end

      at_exit do
        stop
      end
    end

    def respond(record)
      return if !@socket || @socket.closed?
      # I have no idea what I'm doing
      response        = Resolv::DNS::Message.new
      response.qr     = 1
      response.opcode = 0
      response.aa     = 1
      response.rd     = 0
      response.ra     = 0
      response.rcode  = 0
      response.add_answer(record.host, record.ttl, Resolv::DNS::Resource::IN::A.new(record.ip))
      @socket.send(response.encode, 0, MULTICAST_IP, MDNS_PORT)
    end

    def add_record(host, ttl, ip)
      records[host] = Record.new(host, ttl, ip)
      respond(records[host])
    end

    def records
      @records ||= {}
    end

    def hosts
      records.keys
    end

    def reset
      @records = nil
      stop
    end

    def stop
      if @thr
        @thr.kill
        @thr = nil
      end
      if @socket && !@socket.closed?
        @socket.close
      end
    end
  end
end