# frozen_string_literal: true

RSpec::Matchers.define :be_the_same_time_as do |expected|
  match do |actual|
    expect(expected.strftime("%Y-%m-%dT%H:%M:%S%z").in_time_zone).to eq(actual.strftime("%Y-%m-%dT%H:%M:%S%z").in_time_zone)
  end
end
