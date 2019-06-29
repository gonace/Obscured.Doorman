# frozen_string_literal: true

require_relative 'setup'


describe Obscured::Doorman::Base do
  include Rack::Test::Methods

  def app
    Obscured::Doorman::Spec::App
  end

  let!(:email) { 'homer.simpson@obscured.se' }
  let!(:password) { 'Password123' }
  let!(:user) { FactoryBot.create(:user, username: email) }

  describe 'login' do
    def do_login(overrides = {})
      cmd = {}
      cmd[:user] = {}
      cmd[:user][:username] = overrides[:username] if overrides[:username]
      cmd[:user][:password] = overrides[:password] if overrides[:password]
      post '/doorman/login', cmd
    end

    context 'successful' do
      before(:each) {
        do_login(username: email, password: password)
      }

      it 'redirects user to front page (/home)' do
        expect(last_response.status).to eq(302)
        expect(last_response).to be_redirect
        expect(last_response.location).to eq('http://example.org/home')
        follow_redirect!
        expect(last_response.body).to eq('Hello World!')
      end
    end

    context 'unsuccessful' do
      context 'wrong password' do
        before(:each) {
          do_login(username: email, password: 'foo/bar')
        }

        it 'redirects back to login if authentication failed' do
          expect(last_response.status).to eq(302)
          follow_redirect!
          expect(last_response.location).to eq('http://example.org/doorman/login')
        end
      end

      context 'user not confirmed' do
        before(:each) {
          Obscured::Doorman.configuration[:confirmation] = true
          do_login(username: email, password: password)
        }

        after(:each) {
          Obscured::Doorman.configuration[:confirmation] = false
        }

        it 'redirects back to login when authentication failed due to confirmation not completed' do
          expect(last_response.status).to eq(302)
          follow_redirect!
          expect(last_response.location).to eq('http://example.org/doorman/login')
        end
      end
    end
  end

  describe 'register' do
    def do_register(overrides = {})
      cmd = {}
      cmd[:user] = {}
      cmd[:user][:username] = overrides[:username] if overrides[:username]
      cmd[:user][:password] = overrides[:password] if overrides[:password]
      post '/doorman/register', cmd
    end

    context 'successful' do
      before(:each) {
        do_register(username: 'lisa.simpson@obscured.se', password: "#{password}#!")
      }

      it 'redirects user to front page (/home)' do
        expect(last_response.status).to eq(302)
        expect(last_response).to be_redirect
        expect(last_response.location).to eq('http://example.org/home')

        follow_redirect!

        expect(last_response.body).to eq('Hello World!')
      end
    end
  end

  describe 'confirm' do
    def do_confirm(token)
      get "/doorman/confirm/#{token}"
    end

    let!(:token) { FactoryBot.create(:token, type: :confirm, user: user) }

    context 'successful' do
      before(:each) {
        do_confirm(token.token)

        user.reload
      }

      it 'confirms user and removes token' do
        expect(last_response.status).to eq(302)
        expect(user.tokens.where(type: :confirm).count).to eq(0)
      end
    end
  end

  describe 'forget' do
    def do_forgot(overrides = {})
      cmd = {}
      cmd[:user] = {}
      cmd[:user][:username] = overrides[:username] if overrides[:username]
      post '/doorman/forgot', cmd
    end

    let(:token) { user.tokens.where(type: :password).first }

    context 'successful' do
      before(:each) {
        do_forgot(username: user.username)
        user.reload
      }

      it 'confirms user and removes token' do
        expect(last_response.status).to eq(302)
        expect(user.tokens.where(type: :password).count).to eq(1)
      end
    end
  end

  describe 'reset' do
    def do_reset(overrides = {})
      cmd = {}
      cmd[:user] = {}
      cmd[:user][:username] = overrides[:username] if overrides[:username]
      cmd[:user][:token] = overrides[:token] if overrides[:token]
      post '/doorman/reset', cmd
    end
  end

  describe 'configuration' do
    it 'should return default configuration' do
      expect(Obscured::Doorman.default_configuration).to_not be(nil)
    end
  end
end