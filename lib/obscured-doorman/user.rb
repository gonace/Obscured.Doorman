module Obscured
  module Doorman
    class User
      include Mongoid::Document
      include Mongoid::Timestamps
      include BCrypt

      store_in database: Obscured::Doorman.configuration.db_name,
               collection: Obscured::Doorman.configuration.db_collection,
               client: Obscured::Doorman.configuration.db_client

      field :username,              type: String
      field :password,              type: String
      field :salt,                  type: String
      field :first_name,            type: String, default: ''
      field :last_name,             type: String, default: ''
      field :mobile,                type: String, default: ''
      #field :title,                 type: String, default: Obscured::Doorman::Titles::APPRENTICE
      field :role,                  type: Symbol, default: Obscured::Doorman::Roles::ADMIN
      field :confirmed,             type: Boolean, default: true
      field :confirm_token,         type: String
      field :remember_token,        type: String
      #field :created_from,          type: Symbol
      field :last_login,            type: DateTime

      alias email username

      attr_accessor :password_confirmation

      class << self
        def make(opts)
          if User.where(username: opts[:username]).exists?
            raise Obscured::Doorman::Error.new(:already_exists, what: 'User does already exists!')
          end

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
      end


      def name
        "#{first_name} #{last_name}"
      end

      def username=(username)
        if User.where(username: username).exists?
          raise Obscured::Doorman::Error.new(:already_exists, what: 'user')
        end

        self.username = username
      end

      def name=(first_name, last_name)
        self.first_name = first_name
        self.last_name = last_name
      end

      def role=(role)
        self.role = role
      end

      def mobile=(mobile)
        self.mobile = mobile
      end

      def password?(password)
        self.password = Password.create(password)
      end

      def self.authenticate(username, password)
        user = get_by_username(username)
        user if user && user.authenticated?(password)
        nil
      end

      def authenticated?(password)
        password == Password.new(self.password)
      end

      def remember_me!
        self.remember_token = new_token
        save
      end

      def forget_me!
        self.remember_token = nil
        save
      end

      def confirm_email!
        self.confirmed     = true
        self.confirm_token = nil
        save
      end

      def forgot_password!
        self.confirm_token = new_token
        save
      end

      def remembered_password!
        self.confirm_token = nil
        save
      end

      def reset_password!(new_password, new_password_confirmation)
        unless new_password == new_password_confirmation
          false
        else
          self.password_confirmation  = new_password_confirmation
          self.password               = Password.create(new_password) if valid?
          add_history_log('Password has been reset', Obscured::Doorman::Types::SYSTEM)
          save
        end
      end


      protected

      def salt
        if @salt.nil? || @salt.empty?
          secret    = Digest::SHA1.hexdigest("--#{Time.now.utc}--")
          self.salt = Digest::SHA1.hexdigest("--#{Time.now.utc}--#{secret}--")
        end
        @salt
      end

      def encrypt(string)
        Digest::SHA1.hexdigest("--#{salt}--#{string}--")
      end

      def new_token
        encrypt("--#{Time.now.utc}--")
      end

      def validate!
        if valid?
          #self.password = Password.create(password)
          self.confirm_token = new_token
        end
      end
    end
  end
end