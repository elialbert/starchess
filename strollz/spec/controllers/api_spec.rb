require "spec_helper"

describe UsersController, :type => :controller do 
  u1,u2=nil
  before :each do
    User.delete_all
    u1 = User.create({
      :email => 'test1@test.com',
      :first_name => 'testname1'
    })
    u2 = User.create({
      :email => 'test2@test.com',
      :first_name => 'testname2'
    })
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
end
  
