require 'bundler/setup'
Bundler.require

ST = 2
SA = 3
PM = 4
TS = 5

require 'sinatra'
if development?
  require 'sinatra/reloader'
end
require_relative 'results'

get '/' do
  @results = RESULTS
  erb :index
end

post '/refine' do
  @results = RESULTS.select do |result|
    show = true
    if params[:sspt] && !params[:sspt].empty?
      show = (params[:sspt].include?('ST') && !result[ST].empty?) || (params[:sspt].include?('SA') && !result[SA].empty?) || (params[:sspt].include?('PM') && !result[PM].empty?) || (params[:sspt].include?('TS') && !result[TS].empty?)
    end
    show
  end
  erb :index
end

# get '/erb' do
#   @message = 'コラボレイティブ開発特論'
#   erb :erb
# end
# 
# get '/haml' do
#   haml :haml
# end
