#!/usr/bin/ruby
# Factrizes integers in followee's tweets
# usage: ruby factorize-timeline.rb
#
require 'rubygems'
require 'tw'
require 'prime'

class Array
  def reject_dup
    r = Array.new
    f = Hash.new
    self.each do |e|
      unless f[e]
        r << e
        f[e] = true
      end
    end
    return r
  end
end

Tw::Auth.get_or_regist_user(nil)
self_user = Tw::Conf['default_user']

client = Tw::Client.new
client.auth

puts "Following user stream and tweeting as @#{self_user}"
Tw::Client::Stream.new(self_user).user_stream do |tweet|
	next if tweet.user == self_user
	next if tweet.text =~ /\ART @/
	nums = tweet.text.scan(/[\d\.]+/).reject{|e| e =~ /\./}.map{|e| e.to_i}.reject{|e| e <= 1}.reject_dup
	next if nums.empty?

	factors = nums.map{|n|
		"#{n}=" + Prime.prime_division(n).reverse.map{|b,e|
			e > 1 ? "#{b}^#{e}" : b.to_s
		}.join('×')
	}

	puts tweet.url
	text = factors.shift
	while not factors.empty? and text.length < 140 - factors[0].length - 1
		text += " " + factors.shift
	end
	client.tweet(text) if text.length < 140
end