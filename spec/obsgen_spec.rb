require 'spec_helper'

float_regex  = /(\-?\d+(\.\d+)?)/
coords_regex = /#{float_regex},\s*#{float_regex}/

# 1. Start rabbitmq server
# 2. Start redch-webapp server
# 3. Point browser to localhost:3000
# 4. Run `rspec spec`
describe Obsgen do
  it 'generates random observations' do
    exchange = 'samples'

    ENV['PATH'] = "./bin:#{ENV['PATH']}"
    pid, stdin, stdout, stderr = Open4::popen4('obsgen', 'publish', exchange, '--verbose')

    expected_format = /^data: {\"action\":\"(add|delete)\",\"coord\":\[#{coords_regex}\]}\n$/

    # When test isolated (no rabbitmq server running)
    expect(stderr.read).to eq("*** Could not connect: [Errno 61] Connection refused\n")
    expect(stdout.read).to match expected_format
  end
end

describe '#random_observation' do
  subject { Obsgen::random_observation }

  it { should be_a Hash}
  it { should include "action" }
  it { should include "coord" }
  its(["action"]) { should match /^(add|delete)$/ }
  its(["coord"]) { should be_an Array }

  it 'generates valid coordinates' do
    expect(subject["coord"][0].to_s).to match /^#{float_regex}$/
    expect(subject["coord"][1].to_s).to match /^#{float_regex}$/
  end
end
