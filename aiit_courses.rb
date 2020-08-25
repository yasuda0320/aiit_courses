require 'bundler/setup'
Bundler.require
require_relative 'constants'
require_relative 'results'
require_relative 'faculty'

require 'sinatra'
if development?
  # 開発中は再起動しないでよいように自動リロード
  require 'sinatra/reloader'
end

########################################
# トップページの処理
########################################
get '/' do
  @base_url = BASE_URL
  @faculty = FACULTY
  @search = ''
  @checks = [false, false, false, false]
  @results = RESULTS
  erb :index
end

########################################
# 絞り込みボタンを押された時の処理
########################################
post '/refine' do
  @base_url = BASE_URL
  @faculty = FACULTY
  @search = params[:search] || ''
  @results = RESULTS.select do |result|
    @search.empty? || result[COURSE] =~ /#{@search}/ || result[TEACHER] =~ /#{@search}/
  end
  
  @checks = [
    !!params[:sspt]&.include?('ST'),
    !!params[:sspt]&.include?('SA'),
    !!params[:sspt]&.include?('PM'),
    !!params[:sspt]&.include?('TS')
  ]
  @results.select! do |result|
    show = true
    if params[:sspt] && !params[:sspt].empty?
      show = (params[:sspt].include?('ST') && !result[ST].empty?) || (params[:sspt].include?('SA') && !result[SA].empty?) || (params[:sspt].include?('PM') && !result[PM].empty?) || (params[:sspt].include?('TS') && !result[TS].empty?)
    end
    show
  end
  erb :index
end
