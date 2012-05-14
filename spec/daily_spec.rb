require 'spec_helper'

describe Rack::Throttle::Daily do
  include Rack::Test::Methods

  let(:app) { Rack::Throttle::Daily.new(target_app, :max_per_day => 3) }

  it "should be allowed if not seen this day" do
    get "/foo"
    last_response.body.should show_allowed_response
  end
  
  it "should be allowed if seen fewer than the max allowed per day" do
    2.times { get "/foo" }
    last_response.body.should show_allowed_response
  end
  
  it "should not be allowed if seen more times than the max allowed per day" do
    4.times { get "/foo" }
    last_response.body.should show_throttled_response
  end
  
  it "should not count yesterdays requests against today" do
    Timecop.freeze(Date.today - 1) do
      4.times { get "/foo" }
      last_response.body.should show_throttled_response
    end

    get "/foo"
    last_response.body.should show_allowed_response
  end
  
  it "should issue Retry-After: 86400" do
    app.should_receive(:allowed?).and_return(false)
    get "/foo"
    last_response.headers["Retry-After"].should  == "86400"
  end
  
end