class User < ActiveRecord::Base
  acts_as_mappable
  include RocketPants::Cacheable
  has_and_belongs_to_many :attending, -> { uniq }, class_name: "Event"
  has_many :created_events, class_name: "Event", foreign_key: "creator_id"
  has_many :ratings, class_name: "Rating", foreign_key: "user_to_id"
  has_many :attend_requests, class_name: "Attendrequest", foreign_key: "user_id"
end
