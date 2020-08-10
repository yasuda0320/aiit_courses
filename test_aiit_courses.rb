ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require_relative 'aiit_courses'

class TestAiitCourses < Minitest::Test
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end
  
  def test_root
    get '/'
    assert last_response.ok?
  end
end
