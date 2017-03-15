#!/usr/bin/ruby
# Factrizes integers in followee's tweets
# usage: ruby factorize-timeline.rb
#
require 'rubygems'
require 'tw'
require 'prime'
require 'timeout'
require 'unf'

WAIT_DEFAULT = 10 # initial wait (sec) for exponentilal back off
PRIMEDIV_TIMEOUT = 30	# time (sec) allowed to factorize

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
		text = UNF::Normalizer.normalize(self, :nfkc).gsub(/,(\d{3})(?!\d)/, '\1')
		text.scan(/[\d\.]+/).reject{|e| e =~ /\.\d/}.map{|e| e.to_i}
	end

	def no_urls
		self.gsub(URI.regexp, ' ')
	end

	def no_usernames
		self.gsub(/(?!\w)@\w+/, ' ')
	end
end

def factorize(n)
	begin
		primes = Timeout.timeout(PRIMEDIV_TIMEOUT){Prime.prime_division(n)}
		if primes.length == 1 and primes[0][1] == 1
			"#{n}は素数です"
		else
			"#{n}=" + primes.reverse.map{|b, e|
				e > 1 ? "#{b}^#{e}" : b.to_s
			}.join('×')
		end
	rescue Timeout::Error
			"#{n}を素因数分解する時間がありませんでした"
	end
end

module Tw
	class Tweet
		def url_no_mention
			"https://twitter.com/#{user}-/status/#{id}"
		end
	end
end

if __FILE__ == $0
	$stdout.sync = true
	Tw::Auth.get_or_regist_user(nil)
	self_user = Tw::Conf['default_user']

	client = Tw::Client.new
	client.auth

	wait_on_error = WAIT_DEFAULT

	puts "Following user stream and tweeting as @#{self_user}"
	loop do
		begin
			Tw::Client::Stream.new(self_user).user_stream do |tweet|
				next if tweet.user == self_user
				next if tweet.text =~ /\ART @/
				nums = tweet.text.no_urls.no_usernames.integers.reject{|e| e <= 1}.reject_dup
				next if nums.empty?

				factors = nums.map{|n| factorize(n)}

				puts "\n#{tweet.url}\n#{tweet.text}"


				text = ''
				ref = ''
				opts = {}
				if tweet.text =~ /\A@#{self_user} /
					text = "@#{tweet.user} "
					opts[:in_reply_to_status_id] = tweet.id
				else
					ref = ' ' + tweet.url_no_mention
				end
				text += factors.shift
				while not factors.empty? and text.length < 140 - factors[0].length - 1 - ref.length
					text += " " + factors.shift
				end
				text += ref
				puts "sending: #{text}"
				client.tweet(text, opts) if text.length < 140
				wait_on_error = WAIT_DEFAULT
			end
		rescue Net::ReadTimeout, Net::OpenTimeout, Errno::EHOSTUNREACH, Twitter::Error::Unauthorized, EOFError => e
			puts e.message
			puts e.backtrace
		end
		puts "#{Time.now.utc}: Retrying after #{wait_on_error} seconds"
		sleep wait_on_error
		wait_on_error *= 1.5
	end
end
