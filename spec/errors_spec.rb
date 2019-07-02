# frozen_string_literal: true

require 'setup'

describe Obscured::Doorman::Error do
  let!(:error) { Obscured::Doorman::Error .new(:already_exists, what: 'foo/bar') }

  it 'initializes' do
    expect(error.message).to eq('foo/bar')
  end
end