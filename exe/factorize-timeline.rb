#!/usr/bin/ruby
# Factrizes integers in followee's tweets
# usage: ruby factorize-timeline.rb
#
require 'rubygems'
require 'tw'
require 'prime'

Tw::Auth.get_or_regist_user(nil)
self_user = Tw::Conf['default_user']

client = Tw::Client.new
client.auth

puts "Following user stream and tweeting as @#{self_user}"
Tw::Client::Stream.new(self_user).user_stream do |tweet|
	next if tweet.user == self_user
	nums = tweet.text.scan(/(?:[^-\.\d]|\A)(\d+)(?:[^\.\d]|\z)/).map{|e| e[0].to_i}.reject{|e| e <= 1}
	next if nums.empty?

	factors = nums.map{|n|
		"#{n}=" + Prime.prime_division(n).reverse.map{|b,e|
			e > 1 ? "#{b}^#{e}" : b.to_s
		}.join('×')
	}

	text = ''
	max = 140 - tweet.url.char_length_with_t_co
	while not factors.empty? and text.length < max - factors[0].length
		text += factors.shift + " "
	end
	text += tweet.url
	client.tweet(text)
end
