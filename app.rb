# -*- coding:utf-8 -*-
Encoding.default_external = 'utf-8'
require 'sinatra'
require 'redis'
require 'haml'

class LikeTwitter < Sinatra::Base
  
  LOCAL_HOST = '127.0.0.1'
  PORT = '6379'
    
  #login
  get '/' do
    haml :loginform
  end
  
  post '/login' do
    userName = params[:name]
    password = params[:pass]
    
    #DBのハッシュと比較的な
    
    redis = Redis.new(:host => LOCAL_HOST, :port => PORT)
    userId = redis.get("name:#{userName}:uid")
    dbPass = redis.get("uid:#{userId.to_s}:pass")
    
    if dbPass == password
      rand = (("a".."z").to_a + ("A".."Z").to_a + (0..9).to_a).shuffle[0..7].join
      redis.set("uid:#{userId.to_s}:auth", rand)
      response.set_cookie "auth", rand
      
      redirect to "/home?name=#{userName}"
    else
      redirect to "/"
    end
  end

  #regist
  get '/registform' do
    haml :registuserform
  end
  
  post '/userregist' do
    userName = params[:name]
    password = params[:pass]
    
    redis = Redis.new(:host => LOCAL_HOST, :port => PORT)

    if redis.exists "name:#{userName}:uid"
      haml :already_user_exist
    else
      userId = redis.incr("global:NextUserID")
      redis.set("uid:#{userId.to_s}:name", userName)
      redis.set("uid:#{userId.to_s}:pass", password)
      redis.set("name:#{userName}:uid", userId)
      
      redirect to '/'
    end
  end
  
  #ホーム画面
  get '/home' do
    cookie = request.cookies['auth']
    
    userName = params[:name]
    
    redis = Redis.new(:host => LOCAL_HOST, :port => PORT)
    userId = redis.get("name:#{userName}:uid")
    redCookie = redis.get("uid:#{userId.to_s}:auth")
    
    if cookie != redCookie
      redirect to "/"
    else
      @userName = userName
      @twi = redis.lrange("uid:#{userId.to_s}:timeline", 0, -1)
      
      haml :index
    end
  end
    
  #ツイートポスト
  post '/tweet' do
    userName = params[:userName]
    
    redis = Redis.new(:host => LOCAL_HOST, :port => PORT)

    userId = redis.get("name:#{userName}:uid")
    redis.lpush("uid:#{userId.to_s}:timeline", Time.now.to_s + "|" + params[:tweet])
    
    redirect to "/home?name=#{userName}"
  end
  
  get '/logout' do
    redis = Redis.new(:host => LOCAL_HOST, :port => PORT)
    rand = (("a".."z").to_a + ("A".."Z").to_a + (0..9).to_a).shuffle[0..7].join
    response.set_cookie "auth", rand
    
    redirect to "/"
  end
    
end
