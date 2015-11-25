require "spec_helper"

describe UsersController, :type => :controller do   
  u1,u2,e1=nil
  before :each do
    # request.env['omniauth.auth'] = set_omniauth()
    User.delete_all
    Event.delete_all
    u1 = User.create({
      :email => 'test1@test.com',
      :first_name => 'testname1',
      :lat => 41.928249,
      :lng => -87.717069
    })
    sign_in :user, u1
    u2 = User.create({
      :email => 'test2@test.com',
      :first_name => 'testname2',
      :lat => 40.92680,
      :lng => -86.718957
    })

    e1 = Event.create({
      :title => "test event",
      :description => "test description",
      :creator => u1,
      :lat => 41.92680,
      :lng => -87.718957
    })
  end

  it "mostly has authentication" do
    sign_out u1
    expect { get :index, :version => 1 }.to raise_error
  end

  it "can get users" do

    response = get :index, :version => 1
    expect(response).to be_successful
    expect(response.parsed_body['response'].length).to eq(2)
    expect(response.parsed_body['response'][0]['email']).to eq('test1@test.com')
  end

  it "can get a particular user" do
    response = get :show, :version => 1, :id => u2.id
    expect(response).to be_successful
    expect(response.parsed_body['response']['first_name']).to eq('testname2')
  end

  it "can create/update a user" do
    data = {"user" => {"email" => "test3@test.com"}, "version" => 1}
    response = post :create, data
    expect(response).to be_successful

    response = get :index, :version => 1
    new_user = response.parsed_body['response'][2]
    expect(new_user['email']).to eq('test3@test.com')

    data = {"user" => {"first_name"=>"poo"}, "version" => 1, "id" => new_user['id']}
    response = patch :update, data
    expect(response).to be_successful
    response = get :show, :version => 1, :id => new_user['id']
    expect(response.parsed_body['response']['first_name']).to eq('poo')
  end 

  it "can handle location awareness" do
    # find events near user 1
    expect(Event.within(1, :origin => u1).count).to eq(1)
    expect(Event.within(1, :origin => u2).count).to eq(0)
  end

end       