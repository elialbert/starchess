require "spec_helper"

describe RatingsController, :type => :controller do   
  u1,u2,e1=nil
  before :each do
    User.delete_all
    Event.delete_all
    Rating.delete_all
    u1 = User.create({
      :email => 'test1@test.com',
      :first_name => 'testname1'
    })
    sign_in :user, u1

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

  it "can create and show ratings" do
    response = get :index, :version => 1 
    expect(response).to be_successful
    expect(response.parsed_body['response'].length).to eq(0)

    data = {"version" => 1, "rating" => {"user_from_id" => u1.id, 
        "user_to_id" => u2.id, "event_id" => e1.id, "score" => 5, "blurb" => "test rating"}}
    response = post :create, data 
    expect(response).to be_successful
    data = {"version" => 1, "rating" => {"user_from_id" => u2.id, 
        "user_to_id" => u1.id, "event_id" => e1.id, "score" => 3, "blurb" => "test rating2"}}
    response = post :create, data 
    expect(response).to be_successful

    response = get :index, :version => 1 
    expect(response).to be_successful    
    expect(response.parsed_body['response'].length).to eq(2)
    expect(response.parsed_body['response'][0]['blurb']).to eq('test rating')
  end
end