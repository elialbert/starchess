class Attendrequest < ActiveRecord::Base
  include RocketPants::Cacheable

  def self.responses
    {
      :UNREPLIED => 0,
      :ACCEPTED => 1,  
      :REJECTED => 2
    }
  end
   
  belongs_to :user
  belongs_to :event

  validates_presence_of :user, :event

  # todo: need fk integrity on join table to prevent dupes
  def change_response(response)
    response = response['response'].to_i
    update(:response => response)
    if response == Attendrequest.responses[:ACCEPTED]
      user.attending << event
    end
    if response == Attendrequest.responses[:REJECTED]
      user.attending.delete event
    end
  end
end
