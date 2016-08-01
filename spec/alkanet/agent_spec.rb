require 'spec_helper'

describe Alkanet::Agent do
  it 'has a version number' do
    expect(Alkanet::Agent::VERSION).not_to be nil
  end
end
