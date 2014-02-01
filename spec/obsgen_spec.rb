require 'spec_helper'
require 'open4'

float_regex  = /(\-?\d+(\.\d+)?)/
coords_regex = /#{float_regex},\s*#{float_regex}/
cmd_regex = /rabbitmqadmin publish exchange=([\w]+) routing_key='' payload='(.*)'/

describe Obsgen do
  let(:exchange) { 'samples' }
  let(:payload) { { 'a' => 'b' } }

  describe '#random_observation' do
    subject { Obsgen::CLI.random_observation }

    it { should be_a Hash}
    it { should include "action" }
    it { should include "coord" }
    it { should include "value" }
    its(['action']) { should match /^(add|delete)$/ }

    it 'generates valid coordinates' do
      expect(subject["coord"][0].to_s).to match /^#{float_regex}$/
      expect(subject["coord"][1].to_s).to match /^#{float_regex}$/
    end
  end

  describe '#publish_to_exchange' do
    let(:invalid_exchange) { 'foo' }

    it 'publishes the given payload to the exchange' do
      stdout, stderr = Obsgen::CLI.publish_to_exchange(payload, exchange)
      expect(stdout).to eq "Message published\n"
    end

    it 'returns errors if any' do
      stdout, stderr = Obsgen::CLI.publish_to_exchange(payload, invalid_exchange)
      expect(stderr).to_not be_nil
    end
  end

  describe '#publish' do
    let(:cli) { Obsgen::CLI.new }

    it 'publishes a random observation' do
      expect(Obsgen::CLI).to receive(:random_observation)
      cli.publish(exchange)
    end

    context 'with --verbose' do
      it 'outputs the payload' do
        allow(Obsgen::CLI).to receive(:random_observation).and_return(payload)
        allow(cli).to receive(:options).and_return(verbose: true)
        $stdout = StringIO.new

        cli.publish(exchange)
        expect($stdout.string).to eq payload.to_json + "\n"
      end
    end
  end
end
