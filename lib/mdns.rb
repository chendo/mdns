require "mdns/version"
require "net/dns"

class MDNS
  MULTICAST_IP = '224.0.0.251'
  MDNS_PORT = 5353

  class << self
    def start
      @socket = UDPSocket.new
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, true)
      ip_mreq = IPAddr.new(MULTICAST_IP).hton + IPAddr.new('0.0.0.0').hton
      @socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, ip_mreq)
      @socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_TTL, 255)
      @socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_MULTICAST_TTL, 255)
      @socket.bind(Socket::INADDR_ANY, MDNS_PORT)
      Thread.abort_on_exception = true
      @thr = Thread.new do
        loop do
          data = @socket.recv(1024)
          next unless data[0...4] == "\x00\x00\x00\x00" # Filter out non-queries
          packet = begin
            Net::DNS::Packet::parse(data)
          rescue => e
            # Net::DNS::Packet doesn't handle a bunch of mDNS packets
          end
          next if packet.nil?
          if packet.header.query? && packet.question.any? { |q| hosts.include?(q.qName.downcase) && q.qType.to_s == 'A' }
            respond_to(packet)
          end
        end
      end

      records.values.each do |record|
        respond_with(record)
      end

      at_exit do
        stop
      end
    end

    def respond_to(query)
      record = records[query.question.first.qName.downcase]
      respond_with(record)
    end

    def respond_with(record)
      # I have no idea what I'm doing
      response = Net::DNS::Packet.new(record.name)
      response.header.qr = true
      response.header.aa = true
      response.header.anCount = 1
      response.header.arCount = 1
      response.answer = record
      @socket.send(response.data, 0, MULTICAST_IP, MDNS_PORT)
    end

    def add_record(record)
      if record.is_a?(String)
        record = Net::DNS::RR.new(record)
      end
      records[record.name.downcase] = record
      respond_with(record) if @socket && !@socket.closed?
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
