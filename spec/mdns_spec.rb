require 'spec_helper'
require 'resolv'

describe MDNS do
  let(:host) { "foo-bar-#{rand(1000)}.local" }
  let(:ip) { "10.10.10.10" }

  before do
    MDNS.reset
  end

  def resolve(hostname)
    results = []
    begin
      Timeout.timeout(5) do
        Resolv::MDNS.new.each_address(hostname) do |addr|
          results << addr.to_s
        end
      end
    rescue Timeout::Error
    end
    results
  end

  describe "integration test" do

    context "MDNS not running" do
      it "does not resolve" do
        expect(resolve(host)).to be_empty
      end
    end

    context "MDNS is running" do
      before do
        MDNS.add_record(host, 120, ip, "fe80::1")
        MDNS.start
      end

      it "does resolve" do
        expect(resolve(host)).to eq([ip, "FE80::1"])
      end
    end
  end
end
