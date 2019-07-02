# frozen_string_literal: true

require_relative 'setup'

describe Obscured::Doorman::Mailer do
  let(:service) do
    Obscured::Doorman::Mailer.new(
      to: 'homer.simpson@obscured.se',
      subject: 'foo/bar',
      text: 'text',
      html: '<html></html>'
    )
  end

  #before(:each) { allow_any_instance_of(Mail).to receive(:deliver).and_return(true) }

  context 'deliver!' do
    it 'sends mail upon calling .deliver!' do
      #allow_any_instance_of(Mail).to receive(:deliver).and_return(true)

      #expect(service.deliver!).to_not be(nil)
    end
  end
end