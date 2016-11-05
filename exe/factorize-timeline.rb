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

class String
	def integers
		self.gsub(/,(\d{3})(?!\d)/, '\1').scan(/[\d\.]+/).reject{|e| e =~ /\.\d/}.map{|e| e.to_i}
	end

	def no_urls
		self.gsub(URI.regexp, ' ')
	end

	def no_usernames
		self.gsub(/(?!\w)@\w+/, ' ')
	end
end

if __FILE__ == $0
	Tw::Auth.get_or_regist_user(nil)
	self_user = Tw::Conf['default_user']

	client = Tw::Client.new
	client.auth

	puts "Following user stream and tweeting as @#{self_user}"
	begin
		Tw::Client::Stream.new(self_user).user_stream do |tweet|
			next if tweet.user == self_user
			next if tweet.text =~ /\ART @/
			nums = tweet.text.no_urls.no_usernames.integers.reject{|e| e <= 1}.reject_dup
			next if nums.empty?

			factors = nums.map{|n|
				primes = Prime.prime_division(n)
				if primes.length == 1 and primes[0][1] == 1
					"#{n}は素数です"
				else
					"#{n}=" + primes.reverse.map{|b, e|
						e > 1 ? "#{b}^#{e}" : b.to_s
					}.join('×')
				end
			}

			puts "\n#{tweet.url}\n#{tweet.text}"

			text = ''
			opts = {}
			if tweet.text =~ /\A@#{self_user} /
				text = "@#{tweet.user} "
				opts[:in_reply_to_status_id] = tweet.id
			end
			text += factors.shift
			while not factors.empty? and text.length < 140 - factors[0].length - 1
				text += " " + factors.shift
			end
			puts "sending: #{text}"
			client.tweet(text, opts) if text.length < 140
		end
	rescue Net::ReadTimeout => e
		puts e
		retry
	end
end
