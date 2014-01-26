require 'spec_helper'

float_regex  = /(\-?\d+(\.\d+)?)/
coords_regex = /#{float_regex},\s*#{float_regex}/

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
end
