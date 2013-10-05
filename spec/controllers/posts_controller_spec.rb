require 'spec_helper'

describe PostsController do
  before :each do
    SpecApp.app = PostsController
    
    100.times {|i| Post.create!(:title => "tt#{i}", :content => "cc#{i}") }
  end


  describe 'index' do
    it 'default' do
      get '/'
      
      last_response.should be_ok

      data = JSON(last_response.body)
      data['ok'].should == true
      data['items'].count.should == 10
      data['current_page'].should == 1
      data['count_pages'].should == 10
      data['perpage'].should == 10
    end


    it 'paging' do
      get '/', {:page => 2, :perpage => 20}
      
      last_response.should be_ok

      data = JSON(last_response.body)
      data['ok'].should == true
      data['items'].count.should == 20
      data['current_page'].should == 2
      data['count_pages'].should == 5
      data['perpage'].should == 20
    end



    it 'last page' do
      get '/', {:page => 2, :perpage => 60}
      
      last_response.should be_ok

      data = JSON(last_response.body)
      data['ok'].should == true
      data['items'].count.should == 40
      data['current_page'].should == 2
      data['count_pages'].should == 2
      data['perpage'].should == 60
    end


    it 'one page' do
      get '/', {:page => 1, :perpage => 600}
      
      last_response.should be_ok

      data = JSON(last_response.body)
      data['ok'].should == true
      data['items'].count.should == 100
      data['current_page'].should == 1
      data['count_pages'].should == 1
      data['perpage'].should == 600
    end


    it 'sort by created_at' do

    end
  end



  describe 'show' do
    it 'default' do
      get '/show', :id => Post.first.id.to_s

      last_response.should be_ok

      data = JSON(last_response.body)
      data['title'].should_not == nil
      data['content'].should_not == nil
      data['created_at'].should_not == nil
      data['updated_at'].should_not == nil
    end


    it 'no found id' do
      get '/show', :id => 'no found id'

      last_response.should be_bad_request

      data = JSON(last_response.body)
      data['error'].should == Sky::RUNING_TIME_ERROR
      data['error_desc'].should_not == nil
    end
  end



  describe 'create' do
    it 'no permission' do
      expect {
        post '/create', :title => 'test t', :content => 'test c'

        last_response.should be_bad_request
        error_should(last_response, Sky::NoPermissionError.new)
      }.to change(Post, :count).by(0)
    end


    it 'by admin' do
      user = get_user('admin', User::ADMIN)
      req_args = {:title => 'test t', :content => 'test c'}

      expect {
        post '/create', req_args, valid_session(:user_id => user.id.to_s)

        last_response.should be_ok
      }.to change(Post, :count).by(1)

      data = JSON(last_response.body)
      data['ok'].should == true
      data['post']['_id'].should_not == nil
      data['post']['title'].should == 'test t'
      data['post']['content'].should == 'test c'
    end
  end



  describe 'update' do
    before :each do
      @post = Post.create(:title => 'test t', :content => 'test c')
    end

    it 'no permission' do
      expect {
        post '/update', :title => 'tt', :content => 'cc', :id => @post.id.to_s

        last_response.should be_bad_request
        error_should(last_response, Sky::NoPermissionError.new)
      }.to change(Post, :count).by(0)
    end


    it 'by admin' do
      user = get_user('admin', User::ADMIN)
      req_args = {:title => 'tt', :content => 'cc', :id => @post.id.to_s}

      expect {
        post '/update', req_args, valid_session(:user_id => user.id.to_s)

        last_response.should be_ok
      }.to change(Post, :count).by(0)

      data = JSON(last_response.body)
      data['ok'].should == true
      @post.reload
      @post.title.should == req_args[:title]
      @post.content.should == req_args[:content]
    end
  end
end
