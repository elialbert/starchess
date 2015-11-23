class Event < ActiveRecord::Base
  has_and_belongs_to_many :attendees, class_name: "User" 
  belongs_to :creator, class_name: "User"
end
