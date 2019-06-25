# frozen_string_literal: true

require_relative 'setup'

describe Obscured::Doorman::User do
  before(:each) {
    Obscured::Doorman::User.delete_all
  }

  let!(:email) { 'homer.simpson@obscured.se' }
  let!(:password) { 'Password123!' }

  context 'make' do
    let!(:user) { Obscured::Doorman::User.make(username: email, password: password) }

    it 'returns an unsaved document' do
      pp user

      expect(user).to_not be_nil
      expect(user.persisted?).to be(false)
    end
  end
end