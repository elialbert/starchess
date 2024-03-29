class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :omniauth_providers => [:github, :facebook]

  # acts_as_mappable
  # include RocketPants::Cacheable
  has_and_belongs_to_many :attending, -> { uniq }, class_name: "Event"
  has_many :created_events, class_name: "Event", foreign_key: "creator_id"
  has_many :ratings, class_name: "Rating", foreign_key: "user_to_id"
  has_many :attend_requests, class_name: "Attendrequest", foreign_key: "user_id"
  has_many :games, class_name: "StarchessGame", foreign_key: "id"

  def self.from_omniauth(auth)
    # crazy testing hack
    if auth.info.email == 'elialbert@gmail.com' and auth.provider == 'facebook'
      auth.info.email = "testeli@gmail.com"
    end
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.encrypted_password = Devise.friendly_token[0,20]
    end
  end
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.github_data"] && session["devise.github_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      elsif data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end
end
