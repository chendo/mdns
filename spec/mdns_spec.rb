require 'spec_helper'
require 'resolv'

describe MDNS do
  let(:host) { "foo-bar-#{rand(1000)}.local." }
  let(:ip) { "10.10.10.10" }

  before do
    MDNS.reset
  end

  describe "integration test" do

    context "MDNS not running" do
      it "does not resolve" do
        expect do
          Socket.gethostbyname(host)
        end.to raise_error(SocketError)
      end
    end

    context "MDNS is running" do
      before do
        MDNS.add_record(host, 120, ip)
        MDNS.start
      end

      it "does resolve" do
        expect(IPSocket.getaddress(host)).to eq(ip)
      end
    end
  end
end