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

  context 'deliver!' do
    let(:result) { service.deliver! }

    context 'successful' do
      before(:each) { allow_any_instance_of(Mail::Message).to receive(:deliver).and_return(true) }

      it 'sends mail upon calling .deliver!' do
        expect(result).to_not be(nil)
      end
    end
  end
end
