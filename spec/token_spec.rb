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

    it 'returns an unsaved token with values' do
      expect(token).to_not be_nil
      expect(token.token).to eq(sha)
      expect(token.persisted?).to be(false)
    end
  end

  context 'make!' do
    let!(:token) { Obscured::Doorman::Token.make!(user: user, type: :password, token: sha) }

    it 'returns an saved token with values' do
      expect(token).to_not be_nil
      expect(token.token).to eq(sha)
      expect(token.type).to eq(:password)
      expect(token.used_at).to eq(nil)
      expect(token.user_id).to_not eq(nil)
      expect(token.persisted?).to be(true)
    end
  end

  context 'use!' do
    let!(:token) { Obscured::Doorman::Token.make!(user: user, type: :password, token: sha) }

    before(:each) { token.use! }

    it 'sets the token as used' do
      expect(token.used_at).to_not be(nil)
      expect(token.used?).to be(true)
    end
  end

  context 'used?' do
    let!(:token) { Obscured::Doorman::Token.make!(user: user, type: :password, token: sha) }

    it 'is should not be used upon creation' do
      expect(token.used?).to be(false)
    end
  end

  context 'usable?' do
    let!(:token) { Obscured::Doorman::Token.make!(user: user, type: :password, token: sha) }

    it 'is should be usable upon creation' do
      expect(token.usable?).to be(true)
    end
  end
end