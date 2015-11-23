class Attendrequest < ActiveRecord::Base
  include RocketPants::Cacheable

  # move to own file
  UNREPLIED = 0
  ACCEPTED = 1
  REJECTED = 2

  belongs_to :user
  belongs_to :event

  validates_presence_of :user, :event

  # todo: need fk integrity on join table to prevent dupes
  def change_response(response)
    response = response['response']
    update(:response => response)
    if response == ACCEPTED
      user.attending << event
    end
    if response == REJECTED
      user.attending.delete event
    end
  end
end
