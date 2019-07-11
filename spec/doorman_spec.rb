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
      before(:each) do
        do_login(username: email, password: password)
      end

      it 'redirects user to front page (/home)' do
        expect(last_response.status).to eq(302)
        expect(last_response).to be_redirect
        expect(last_response.location).to eq('http://example.org/home')
        follow_redirect!
        expect(last_response.body).to eq('Hello World!')
      end

      it 'returns session info' do
        get '/session'

        expect(last_response.status).to eq(200)
      end

      it 'returns user info' do
        get '/user'

        expect(last_response.status).to eq(200)
      end
    end

    context 'unsuccessful' do
      context 'wrong password' do
        before(:each) do
          do_login(username: email, password: 'foo/bar')
        end

        it 'redirects back to login if authentication failed' do
          expect(last_response.status).to eq(302)
          follow_redirect!
          expect(last_response.location).to eq('http://example.org/doorman/login')
        end

        it 'does not return user info' do
          get '/user'

          expect(last_response.status).to eq(403)
        end

        it 'does not return user info' do
          get '/user/xml'

          expect(last_response.status).to eq(403)
        end
      end

      context 'user not confirmed' do
        before(:each) do
          Obscured::Doorman.configuration[:confirmation] = true
          do_login(username: email, password: password)
        end

        after(:each) do
          Obscured::Doorman.configuration[:confirmation] = false
        end

        it 'redirects back to login when authentication failed due to confirmation not completed' do
          expect(last_response.status).to eq(302)
          follow_redirect!
          expect(last_response.location).to eq('http://example.org/doorman/login')
        end
      end
    end
  end

  describe 'logout' do
    def do_login(overrides = {})
      cmd = {}
      cmd[:user] = {}
      cmd[:user][:username] = overrides[:username] if overrides[:username]
      cmd[:user][:password] = overrides[:password] if overrides[:password]
      post '/doorman/login', cmd
    end

    context 'successful' do
      before(:each) do
        do_login(username: email, password: password)
      end

      it 'logs out the user' do
        get '/logout'

        expect(last_response.status).to eq(200)
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
      before(:each) do
        do_register(username: 'lisa.simpson@obscured.se', password: "#{password}#!")
      end

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
      before(:each) do
        do_confirm(token.token)

        user.reload
      end

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
      before(:each) do
        do_forgot(username: user.username)
        user.reload
      end

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
