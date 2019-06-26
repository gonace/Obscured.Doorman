# frozen_string_literal: true

require_relative 'setup'

describe Obscured::Doorman::User do
  before(:each) { Obscured::Doorman::User.delete_all }

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

  context 'name' do
    let!(:user) { FactoryBot.create(:user) }

    before(:each) {
      user.name = { first_name: 'Marge', last_name: 'Simpson' }
      user.save
      user.reload
    }

    it 'updates and returns correct name' do
      expect(user.first_name).to eq('Marge')
      expect(user.last_name).to eq('Simpson')
      expect(user.name).to eq('Marge Simpson')
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

  context 'remember_me' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:result) { user.remember_me! }

    it 'stores and returns token' do
      expect(result).to_not be(nil)
      expect(result.type).to be(:remember)
      expect(result.expires_at).to be_the_same_time_as(DateTime.now + 30.days)
      expect(result.user_id).to eq(user.id)
    end
  end

  context 'forget_me' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:result) { user.remember_me! }

    before(:each) { user.save }

    it 'stores and returns token' do
      expect(result).to_not be(nil)
      expect(result.type).to be(:remember)
      expect(result.expires_at).to be_the_same_time_as(DateTime.now + 30.days)
    end

    it 'removes the saved remember_me token' do
      expect(user.forget_me!).to be(1)
      expect(Obscured::Doorman::Token.where(type: :remember).count).to be(0)
    end
  end

  context 'forget password' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:result) { user.forgot_password! }
    let(:token) { Obscured::Doorman::Token.where(type: :password).first }

    before(:each) { user.save }

    it 'stores and returns token' do
      expect(result).to_not be(nil)
      expect(result.type).to be(:password)
      expect(result.expires_at).to be_the_same_time_as(DateTime.now + 2.hours)
    end

    it 'updates password if reset is successful' do
      expect(user.reset_password!('morotskaka123', result.token)).to be(true)
      expect(user.password?('morotskaka123')).to eq(true)
      expect(token).to_not be(nil)
    end

    it 'returns false if token is not found' do
      expect(user.reset_password!('morotskaka123', 'boogus')).to be(false)
    end

    it 'removes token if user was successfully signed in' do
      expect(user.remembered_password!).to be(1)
      expect(Obscured::Doorman::Token.where(type: :password).count).to be(0)
    end
  end
end