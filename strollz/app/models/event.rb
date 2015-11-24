class Event < ActiveRecord::Base
  acts_as_mappable
  include RocketPants::Cacheable

  has_and_belongs_to_many :attendees, -> { uniq }, class_name: "User"
  belongs_to :creator, class_name: "User"
  validates :creator, :presence => true
end
