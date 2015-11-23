class Attendrequest < ActiveRecord::Base
  include RocketPants::Cacheable

  belongs_to :user
  belongs_to :event
end
