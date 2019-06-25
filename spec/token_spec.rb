# frozen_string_literal: true

require_relative 'setup'

describe Obscured::Doorman::Token do
  before(:each) {
    Obscured::Doorman::Token.delete_all
  }

  let!(:user) { FactoryBot.create(:user) }
  let!(:sha) { Digest::SHA1.hexdigest("--#{user.email}--") }

  context 'make' do
    let!(:token) { Obscured::Doorman::Token.make(user: user, type: :password, token: sha) }

    it 'returns an unsaved document' do
      expect(token).to_not be_nil
      expect(token.token).to eq(sha)
      expect(token.persisted?).to be(false)
    end
  end

  context 'make!' do
    let!(:token) { Obscured::Doorman::Token.make!(user: user, type: :password, token: sha) }

    context 'without tags' do
      it 'returns an saved document' do
        expect(token).to_not be_nil
        expect(token.token).to eq(sha)
        expect(token.type).to eq(:password)
        expect(token.used_at).to eq(nil)
        expect(token.user_id).to_not eq(nil)
        expect(token.persisted?).to be(true)
      end
    end
  end
end