require 'rails_helper'

RSpec.describe "API_V1::Auth", :type => :request do
  # 测试注册的api
  example "register" do
    post "/api/v1/signup", params: { :email => "admin@example.com", :password => "111111"}
    expect(response).to have_http_status(200)
    # 检查数据库中真的有存进去
    new_user = User.last
    expect(new_user.email).to eq("admin@example.com")
    # 检查回传的 JSON
    expect(response.body).to eq( { :user_id => new_user.id }.to_json )
  end

  # 测试注册失败的api
  example "register failed" do
    post "/api/v1/signup", params: { :email => "admin@example.com" }
    # 测试没有传密码，注册失败的情形
    expect(response).to have_http_status(400)
    # 检查回传的 JSON
    expect(response.body).to eq( { :message => "Failed", :errors => {:password => ["can't be blank"]}  }.to_json )
  end


  context "session" do
    before do
      @user = User.create!( :email => "test@example.com", :password => "12345678")
    end
    # 测试登录、登出的api
    example "valid login and logout" do
      post "/api/v1/login", params: { :auth_token => @user.authentication_token,
                                      :email => @user.email, :password => "12345678" }
      expect(response).to have_http_status(200)
      # 检查回传的 JSON
      expect(response.body).to eq(
        {
          :message => "Ok",
          :auth_token => @user.authentication_token,
          :user_id => @user.id
        }.to_json
      )
      post "/api/v1/logout"
      expect(response).to have_http_status(401)
      post "/api/v1/logout", params: { :auth_token => @user.authentication_token }
      expect(response).to have_http_status(200)
      old_token = @user.authentication_token
      @user.reload
      # 检查登出后 `authentication_token` 会改掉
      expect(@user.authentication_token).not_to eq(old_token)
    end

    # 测试登录、登出失败的api
    example "invalid auth token login" do
      post "/api/v1/login", params: { :auth_token => @user.authentication_token,
                                      :email => @user.email, :password => "xxx" }
      # 检查登入失败回传 401
      expect(response).to have_http_status(401)
      expect(response.body).to eq(
        { :message => "Email or Password is wrong" }.to_json
      )
    end
  end
end
