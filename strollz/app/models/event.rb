class Event < ActiveRecord::Base
  include RocketPants::Cacheable

  has_and_belongs_to_many :attendees, class_name: "User" 
  belongs_to :creator, class_name: "User"
  validates :creator, :presence => true
end
