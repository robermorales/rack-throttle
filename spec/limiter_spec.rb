require 'spec_helper'

describe Rack::Throttle::Limiter do
  include Rack::Test::Methods

  describe 'with default config' do
    let(:app) { Rack::Throttle::Limiter.new(target_app) }

    describe "basic calling" do
      it "should return the example app" do
        get "/foo"
        last_response.body.should show_allowed_response
      end

      it "should call the application if allowed" do
        app.should_receive(:allowed?).and_return(true)
        get "/foo"
        last_response.body.should show_allowed_response
      end

      it "should give a rate limit exceeded message if not allowed" do
        app.should_receive(:allowed?).and_return(false)
        get "/foo"
        last_response.body.should show_throttled_response
      end
      
      describe "RFC 6585" do
        it "should return status 429 (Too Many Requests)" do
          app.should_receive(:allowed?).and_return(false)
          get "/foo"
          last_response.status.should == 429
      end
     
  end
      
    end

    describe "allowed?" do
      it "should return true if whitelisted" do
        app.should_receive(:whitelisted?).and_return(true)
        get "/foo"
        last_response.body.should show_allowed_response
      end

      it "should return false if blacklisted" do
        app.should_receive(:blacklisted?).and_return(true)
        get "/foo"
        last_response.body.should show_throttled_response
      end

      it "should return true if not whitelisted or blacklisted" do
        app.should_receive(:whitelisted?).and_return(false)
        app.should_receive(:blacklisted?).and_return(false)
        get "/foo"
        last_response.body.should show_allowed_response
      end
    end
  end

  describe 'with rate_limit_exceeded callback' do
    let(:app) { Rack::Throttle::Limiter.new(target_app, :rate_limit_exceeded_callback => lambda {|request| app.callback(request) } ) }

    it "should call rate_limit_exceeded_callback w/ request when rate limit exceeded" do
      app.should_receive(:blacklisted?).and_return(true)
      app.should_receive(:callback).and_return(true)
      get "/foo"
      last_response.body.should show_throttled_response
    end
  end
  
end