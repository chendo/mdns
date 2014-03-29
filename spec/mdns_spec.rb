require 'spec_helper'
require 'resolv'

describe MDNS do
  let(:domain) { "foo-bar-#{rand(1000)}.local." }
  let(:ip) { "10.10.10.10" }
  describe "integration test" do

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

  describe '.add_record' do
    it "takes a string" do
      MDNS.add_record("#{domain} 60 A #{ip}")
      expect(MDNS.records.keys).to eq([domain])
      expect(MDNS.records.values.first).to be_a(Net::DNS::RR)
    end

    it "takes a Net::DNS::RR" do
      MDNS.add_record(Net::DNS::RR.new("#{domain} 60 A #{ip}"))
      expect(MDNS.records.keys).to eq([domain])
      expect(MDNS.records.values.first).to be_a(Net::DNS::RR)
    end
  end

end