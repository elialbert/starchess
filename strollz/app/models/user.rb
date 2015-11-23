class User < ActiveRecord::Base
  has_and_belongs_to_many :attending, class_name: "Event"
  has_many :created_events, class_name: "Event", foreign_key: "creator_id"
end
