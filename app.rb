# -*- coding:utf-8 -*-
Encoding.default_external = 'utf-8'
require 'sinatra'
require 'redis'
require 'haml'

#class LikeTwitter < Sinatra::Base
    set :environment, :production

    set :haml, :escape_html => true
    
    #URLでアクセス
  get '/login' do
    
        haml :login
  end
    
    #ホーム画面
    get '/home' do
        redis = Redis.new(:host => "127.0.0.1", :port => "6379")
        @userName = params[:name]
        @twi = redis.lrange(@userName , 0, -1)
        
        haml :index
    end
    
    #ツイートポスト
    post '/tweet' do
        #DBへ
        redis = Redis.new(:host => "127.0.0.1", :port => "6379")
        redis.lpush(params[:userName], params[:tweet])
    
        #とりあえず再取得
        @userName = params[:userName]
        @twi = redis.lrange(@userName , 0, -1)
    
        #手動リダイレクト
        haml :index
    end
#end
