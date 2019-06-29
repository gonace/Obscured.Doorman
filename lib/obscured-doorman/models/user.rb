# frozen_string_literal: true

require 'obscured-timeline'

module Obscured
  module Doorman
    class User
      include Mongoid::Document
      include Mongoid::Timestamps
      include Mongoid::Timeline::Tracker

      store_in database: Doorman.configuration.db_name,
               client: Doorman.configuration.db_client,
               collection: 'users'

      field :username, type: String
      field :password, type: String
      field :salt, type: String
      field :first_name, type: String
      field :last_name, type: String
      field :mobile, type: String
      field :role, type: Symbol, default: Doorman::Roles::ADMIN
      field :confirmed, type: Boolean, default: false

      has_many :tokens, autosave: true, class_name: 'Obscured::Doorman::Token', foreign_key: 'user_id'

      index({ username: 1 }, background: true)

      after_initialize :set_salt

      alias email username

      attr_accessor :confirmed

      class << self
        def make(opts)
          raise Doorman::Error.new(:already_exists, what: 'User does already exists!') if User.where(username: opts[:username]).exists?

          user = new
          user.username = opts[:username]
          user.set_password(opts[:password])
          user.first_name = opts[:first_name] unless opts[:first_name].nil?
          user.last_name = opts[:last_name] unless opts[:last_name].nil?
          user.mobile = opts[:mobile] unless opts[:mobile].nil?
          user.role = opts[:role] unless opts[:role].nil?
          user.confirmed = opts[:confirmed] unless opts[:confirmed].nil?
          user.add_event(type: :account, message: 'Account created', producer: opts[:producer].nil? ? user.username : opts[:producer])
          user
        end

        def make!(opts)
          user = make(opts)
          user.save
          user
        end

        def authenticate(username, password)
          user = where(username: username).first
          return user if user&.authenticated?(password)

          nil
        end

        def registered?(username)
          where(username: username).exists?
        end
      end

      def name
        "#{first_name} #{last_name}"
      end

      def name=(arguments)
        self.first_name = arguments[:first_name]
        self.last_name = arguments[:last_name]
      end

      def set_password(password)
        self.password = BCrypt::Password.create(password)
      end

      def authenticated?(password)
        (BCrypt::Password.new(self.password) == password)
      end
      alias password? authenticated?

      def remember_me!
        add_event(type: :remember, message: 'Account set to be remembered upon login', producer: username)
        token = tokens.build(
          type: :remember,
          token: token,
          expires_at: (DateTime.now + Doorman.configuration.remember_for.days)
        )
        save
        token
      end

      def forget_me!
        add_event(type: :remember, message: 'Account set not to be remembered upon login', producer: username)
        tokens.where(type: :remember).destroy
      end

      def confirm!
        add_event(type: :confirmation, message: 'Account was successfully confirmed', producer: username)
        self.confirmed = true
        tokens.where(type: :confirm).destroy
        save
      end

      def forgot_password!
        add_event(type: :password, message: 'Reset password procedure has been started', producer: username)
        token = tokens.build(
          user: self,
          type: :password,
          token: token,
          expires_at: (DateTime.now + 2.hours)
        )
        save
        token
      end

      def remembered_password!
        add_event(type: :password, message: 'Reset password procedure has been cancelled since successful login was achived', producer: username)
        tokens.where(type: :password).destroy
      end

      def reset_password!(password, token)
        token = tokens.find_by(token: token)
        if token && token.type.eql?(:password)
          set_password(password)
          add_event(type: :password, message: 'Password was successfully reset', producer: username)
          return save
        end
        false
      end

      protected

      #def _password(password)
      #  (salt + password)
      #end

      def set_salt
        return unless salt.nil? || salt.empty?

        secret = Digest::SHA1.hexdigest("--#{username}--")
        self.salt = Digest::SHA1.hexdigest("--#{Time.now.utc}--#{secret}--")
      end

      #def encrypt(string)
      #  Digest::SHA1.hexdigest("--#{salt}--#{string}--")
      #end
    end
  end
end
