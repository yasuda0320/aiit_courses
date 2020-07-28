require 'bundler/setup'
Bundler.require

require 'sinatra'
if development?
  require 'sinatra/reloader'
end
require_relative 'result'

get '/' do
  Result.scrape_url
  @results = Result.results
  erb :index
end

get '/erb' do
  @message = 'コラボレイティブ開発特論'
  erb :erb
end

get '/haml' do
  haml :haml
end
