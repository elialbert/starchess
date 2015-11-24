require "spec_helper"

describe EventsController, :type => :controller do   
  u1,u2=nil
  before :each do
    User.delete_all
    Event.delete_all
    u1 = User.create({
      :email => 'test1@test.com',
      :first_name => 'testname1'
    })
    u2 = User.create({
      :email => 'test2@test.com',
      :first_name => 'testname2'
    })

    e1 = Event.create({
      :title => "test event",
      :description => "test description",
      :creator => u1
    })
    e1.attendees << u1
    e1.attendees << u2
  end

  it "can return events with pagination and attendees" do
    response = get :index, :version => 1 
    expect(response).to be_successful
    expect(response.parsed_body['response'].length).to eq(1)
    expect(response.parsed_body['pagination']['pages']).to eq(1)
    expect(response.parsed_body['response'][0]['title']).to eq('test event')
    expect(response.parsed_body['response'][0]['attendees'].length).to eq(2)
  end
end