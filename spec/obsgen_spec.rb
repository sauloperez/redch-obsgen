require 'spec_helper'
require 'open4'

float_regex  = /(\-?\d+(\.\d+)?)/
coords_regex = /#{float_regex},\s*#{float_regex}/
cmd_regex = /rabbitmqadmin publish exchange=([\w]+) routing_key='' payload='(.*)'/

describe Obsgen do
  describe '#random_observation' do
    subject { Obsgen::random_observation }

    it { should be_a Hash}
    it { should include "action" }
    it { should include "coord" }
    it { should include "value" }
    its(["action"]) { should match /^(add|delete)$/ }

    it 'generates valid coordinates' do
      expect(subject["coord"][0].to_s).to match /^#{float_regex}$/
      expect(subject["coord"][1].to_s).to match /^#{float_regex}$/
    end
  end

  describe '#publish_to_exchange' do
    let(:exchange) { 'samples' }

    # it 'publishes the given message to the exchange' do
    #   Obsgen::publish_to_exchange({ 'a' => 'b' }, exchange)

    #   expect(Open4).to receive(:popen4).with(/^#{cmd_regex}$/)
    # end

    it 'returns the std output and std error' do
      std = Obsgen::publish_to_exchange({ 'a' => 'b' }, exchange)
      expect(std.length).to be(2)
    end
  end
end
