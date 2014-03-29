require 'spec_helper'
require 'resolv'

describe MDNS do
  describe "integration test" do
    let(:domain) { "foo-bar-#{rand(1000)}.local." }
    let(:ip) { "10.10.10.10" }

    context "MDNS not running" do
      it "does not resolve" do
        expect do
          Socket.gethostbyname(domain)
        end.to raise_error(SocketError)
      end
    end

    context "MDNS is running" do
      before do
        MDNS.add_record(Net::DNS::RR.new("#{domain} 60 A #{ip}"))
        MDNS.start
      end

      after do
        MDNS.stop
      end

      it "does resolve" do
        expect(Socket.gethostbyname(domain)).to be_a(Array)
      end
    end
  end
end