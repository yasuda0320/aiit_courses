require 'bundler/setup'
Bundler.require

require 'sinatra'
if development?
  require 'sinatra/reloader'
end
require_relative 'results'

get '/' do
  @results = RESULTS
  erb :index
end

get '/erb' do
  @message = 'コラボレイティブ開発特論'
  erb :erb
end

get '/haml' do
  haml :haml
end
