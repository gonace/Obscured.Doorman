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
      expect(user).to_not be_nil
      expect(user.persisted?).to be(false)
    end
  end

  context 'make!' do
    let!(:user) { Obscured::Doorman::User.make!(username: email, password: password, first_name: 'Homer', last_name: 'Simpson') }

    it 'returns an saved document' do
      expect(user).to_not be_nil
      expect(user.persisted?).to be(true)
    end
  end

  context 'optionals and/or defaults' do
    let!(:user) { FactoryBot.create(:user) }

    it 'returns a name' do
      expect(user.name).to eq('Homer Simpson')
    end
    it 'returns a mobile number' do
      expect(user.mobile). to eq('+467855568')
    end
    it 'returns a role' do
      expect(user.role). to eq(:admin)
    end
  end

  context 'authenticate' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:result) { Obscured::Doorman::User.authenticate(user.username, 'Password123') }

    it 'authenticates with correct username and password' do
      expect(result).to_not eq(nil)
      expect(result.username).to eq(user.username)
    end
  end

  context 'password?' do
    let!(:user) { FactoryBot.create(:user) }

    it 'return true if correct password is provided' do
      expect(user.authenticated?('Password123')).to eq(true)
    end
    it 'return false if faulty password is provided' do
      expect(user.password?('123Password')).to eq(false)
    end
  end
end