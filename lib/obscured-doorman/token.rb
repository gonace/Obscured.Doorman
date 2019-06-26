module Obscured
  module Doorman
    class Token
      include Mongoid::Document
      include Mongoid::Timestamps

      store_in database: Doorman.configuration.db_name,
               client: Doorman.configuration.db_client,
               collection: 'tokens'

      field :type, type: Symbol
      field :token, type: String
      field :expires_at, type: DateTime, default: -> { DateTime.now + 2.hours }
      field :used_at, type: DateTime
      field :user_id, type: BSON::ObjectId

      belongs_to :user, autosave: true, class_name: 'Obscured::Doorman::User', inverse_of: 'tokens'

      index({ expires_at: 1 }, background: true, expire_after_seconds: 172800)
      index({ used_at: 1 }, background: true, expire_after_seconds: 345600)

      class << self
        def make(opts)
          raise Doorman::Error.new(:already_exists, what: 'Token does already exists!') if Token.where(user: opts[:user], type: opts[:type]).exists?

          token = new
          token.user = opts[:user]
          token.type = opts[:type]
          token.token = opts[:token]
          token.expires_at = opts[:expires] if opts[:expires]
          token
        end

        def make!(opts)
          token = make(opts)
          token.save
          token
        end
      end

      def use!
        self.used_at = DateTime.now
        save
      end
    end
  end
end