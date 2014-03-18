# -*- coding:utf-8 -*-
Encoding.default_external = 'utf-8'
require 'sinatra'
require 'redis'
require 'haml'

class LikeTwitter < Sinatra::Base
  
  LOCAL_HOST = '127.0.0.1'
  PORT = '6379'
    
  #login
  get '/login_form' do
    haml :loginform
  end
  
  post '/login_action' do
    @userName = params[:name]
    @password = params[:pass]
    
    #DBのハッシュと比較的な
    
    redis = Redis.new(:host => LOCAL_HOST, :port => PORT)
    userId = redis.get("UserName:#{@userName}:UserID")
    pass = redis.get("UserID:#{userId.to_s}:Password")
    
    if pass == @password
      rand = (("a".."z").to_a + ("A".."Z").to_a + (0..9).to_a).shuffle[0..7].join
      redis.set("UserID:#{userId.to_s}:Cookie", rand)
      response.set_cookie "auth", rand
      
      redirect to "/home?name=#{@userName}"
    else
      redirect to "/login_form"
    end
  end

  #regist
  get '/user_regist' do
    haml :registuserform
  end
  
  post '/user_regist_action' do
    @userName = params[:name]
    @password = params[:pass]
    
    #DBへハッシュを
    redis = Redis.new(:host => LOCAL_HOST, :port => PORT)
    userId = redis.incr("global:NextUserID")
    redis.set("UserID:#{userId.to_s}:UserName", @userName)
    redis.set("UserID:#{userId.to_s}:Password", @password)
    redis.set("UserName:#{@userName}:UserID", userId)
    
    redirect to '/login_form'
  end
  
  #ホーム画面
  get '/home' do
    cookie = request.cookies['auth']
    
    @userName = params[:name]
    
    redis = Redis.new(:host => LOCAL_HOST, :port => PORT)
    userId = redis.get("UserName:#{@userName}:UserID")
    redCookie = redis.get("UserID:#{userId.to_s}:Cookie")
    
    if cookie != redCookie
      redirect to "/login_form"
    end

    @twi = redis.lrange("Posts:#{userId.to_s}", 0, -1)
    
    haml :index
  end
    
  #ツイートポスト
  post '/tweet' do
    #DBへ
    redis = Redis.new(:host => LOCAL_HOST, :port => PORT)
    @userName = params[:userName]
    userId = redis.get("UserName:#{@userName}:UserID")
    redis.lpush("Posts:#{userId.to_s}", params[:tweet])
    
    redirect to "/home?name=#{@userName}"
  end
  
    get '/logout_action' do
        redis = Redis.new(:host => LOCAL_HOST, :port => PORT)
        rand = (("a".."z").to_a + ("A".."Z").to_a + (0..9).to_a).shuffle[0..7].join
        response.set_cookie "auth", rand
        
        redirect to "/login_form"
    end
    
end
