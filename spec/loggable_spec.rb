# frozen_string_literal: true

require 'setup'

describe Obscured::Doorman::Loggable do
  describe '#logger=' do
    let(:logger) do
      Logger.new($stdout).tap do |log|
        log.level = Logger::INFO
      end
    end

    before do
      Obscured::Doorman.logger = logger
    end

    it 'sets the logger' do
      expect(Obscured::Doorman.logger).to eq(logger)
    end
  end
end
