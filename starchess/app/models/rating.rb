class Rating < ActiveRecord::Base
  include RocketPants::Cacheable

  belongs_to :user_from, :class_name => 'User'
  belongs_to :user_to, :class_name => 'User'  
  belongs_to :event

  validates_presence_of :user_from, :user_to, :event, :score
end
