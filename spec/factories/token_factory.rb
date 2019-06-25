FactoryBot.define do
  factory :token, :class => Obscured::Doorman::Token do
    type { :password }
    token { Digest::SHA1.hexdigest("--homer.simpsons@obscured.se--") }
  end
end