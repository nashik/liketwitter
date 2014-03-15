# -*- coding:utf-8 -*-
Encoding.default_external = 'utf-8'
require 'sinatra'
require 'redis'
require 'haml'

#class LikeTwitter < Sinatra::Base
    set :environment, :production

    set :haml, :escape_html => true
    
    #URL�ŃA�N�Z�X
  get '/login' do
    
        haml :login
  end
    
    #�z�[�����
    get '/home' do
        redis = Redis.new(:host => "127.0.0.1", :port => "6379")
        @userName = params[:name]
        @twi = redis.lrange(@userName , 0, -1)
        
        haml :index
    end
    
    #�c�C�[�g�|�X�g
    post '/tweet' do
        #DB��
        redis = Redis.new(:host => "127.0.0.1", :port => "6379")
        redis.lpush(params[:userName], params[:tweet])
    
        #�Ƃ肠�����Ď擾
        @userName = params[:userName]
        @twi = redis.lrange(@userName , 0, -1)
    
        #�蓮���_�C���N�g
        haml :index
    end
#end
