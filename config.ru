# -*- encoding: utf-8 -*-
# config.ru

require './app.rb'

Encoding.default_external = 'utf-8'

#外部からアクセスを許可する
set :environment, :production

set :haml, :escape_html => true

run LikeTwitter.new