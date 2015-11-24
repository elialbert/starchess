require "spec_helper"

describe AttendrequestsController, :type => :controller do   
  u1,u2,e1=nil
  before :each do
    User.delete_all
    Event.delete_all
    Rating.delete_all
    Attendrequest.delete_all
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
  end

  it "can create and update attendance" do
    response = get :index, :version => 1 
    expect(response).to be_successful
    expect(response.parsed_body['response'].length).to eq(0)

    data = {"version" => 1, "attendrequest" => {"user_id" => u1.id, 
        "event_id" => e1.id, "message" => "test message"}}
    response = post :create, data 
    expect(response).to be_successful

    response = get :index, :version => 1 
    expect(response).to be_successful    
    expect(response.parsed_body['response'].length).to eq(1)
    expect(e1.attendees.length).to eq(0)

    new_id = response.parsed_body['response'][0]['id']
    data = {"version" => 1, "id" => new_id, "attendrequest" => {"response" => 1}} 
    response = patch :update, data 
    expect(response).to be_successful
    e1 = Event.find(e1.id)
    expect(e1.attendees.length).to eq(1)

    data = {"version" => 1, "id" => new_id, "attendrequest" => {"response" => 5}} 
    response = patch :update, data 
    expect(response).to be_api_error(RocketPants::BadRequest)

  end
end