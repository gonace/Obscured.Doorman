module Obscured
  module Doorman
    class User
      include Mongoid::Document
      include Mongoid::Timestamps
      include BCrypt

      store_in database: Obscured::Doorman.configuration.db_name,
               client: Obscured::Doorman.configuration.db_client,
               collection: 'users'

      field :username, type: String
      field :password, type: String
      field :salt, type: String
      field :first_name, type: String, default: ''
      field :last_name, type: String, default: ''
      field :mobile, type: String, default: ''
      field :role, type: Symbol, default: Obscured::Doorman::Roles::ADMIN
      field :confirmed, type: Boolean, default: true
      #field :confirm_token, type: String
      #field :remember_token, type: String
      field :last_login, type: DateTime

      has_many :tokens

      alias email username

      class << self
        def make(opts)
          raise Obscured::Doorman::Error.new(:already_exists, what: 'User does already exists!') if User.where(username: opts[:username]).exists?

          user = new
          user.username = opts[:username]
          user.password = Password.create(opts[:password])
          user.confirmed = opts[:confirmed] unless opts[:confirmed].nil?
          user
        end

        def make!(opts)
          user = make(opts)
          user.save
          user
        end

        def authenticate(username, password)
          user = find_by(username: username)
          user if user && user.authenticated?(password)
          nil
        end
      end


      def name
        "#{first_name} #{last_name}"
      end

      def name=(first_name, last_name)
        self.first_name = first_name
        self.last_name = last_name
      end

      def password?(password)
        self.password = Password.create(password)
      end

      def authenticated?(password)
        password == Password.new(self.password)
      end

      def remember_me!
        Obscured::Doorman::Token.make!(
          user: self,
          type: :remember,
          token: token,
          expires: Obscured::Doorman.configuration.remember_for.days.seconds
        )
      end

      def forget_me!
        self.tokens.delete(type: :remember)
      end

      def confirm_email!
        self.confirmed = true
        self.tokens.delete(type: :confirm)
        save
      end

      def forgot_password!
        Obscured::Doorman::Token.make!(
          user: self,
          type: :password,
          token: token,
          expires: 2.hours.seconds
        )
      end

      def remembered_password!
        self.tokens.delete(type: :password)
        save
      end

      def reset_password!(password, token)
        token = self.tokens.where(token: token)
        unless token
          self.password = Password.create(password)
          save
        end
        false
      end


      protected

      def salt
        if @salt.nil? || @salt.empty?
          secret = Digest::SHA1.hexdigest("--#{username}--")
          self.salt = Digest::SHA1.hexdigest("--#{Time.now.utc}--#{secret}--")
        end
        @salt
      end

      def encrypt(string)
        Digest::SHA1.hexdigest("--#{salt}--#{string}--")
      end

      def token
        encrypt("--#{username}/#{Time.now.utc}--")
      end
    end
  end
end