class User < ApplicationRecord
  has_many :pages
  rolify

	def self.create_facebook(auth)
    where(provider: auth["provider"], uid: auth["id"]).first_or_initialize.tap do |user|
      user.provider = auth["provider"]
      user.uid = auth["id"]
      user.oauth_token = auth["access_token"]
      user.first_name = auth["first_name"]
      user.last_name = auth["last_name"]
      user.save!
    end
  end

  def clearance_levels
    # Array of role names
    roles.pluck(:name)
  end
end
