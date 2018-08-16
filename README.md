# factorize-timeline
Factrizes integers in followee's tweets

2018-08-16 17:00 UTC: This program no longer works as Twitter retired userstream.

```
end of file reached
/usr/lib/ruby/2.3.0/openssl/buffering.rb:125:in `sysread'
/usr/lib/ruby/2.3.0/openssl/buffering.rb:125:in `readpartial'
./vendor/bundle/ruby/2.3.0/gems/twitter-6.2.0/lib/twitter/streaming/connection.rb:19:in `stream'
./vendor/bundle/ruby/2.3.0/gems/twitter-6.2.0/lib/twitter/streaming/client.rb:119:in `request'
./vendor/bundle/ruby/2.3.0/gems/twitter-6.2.0/lib/twitter/streaming/client.rb:93:in `user'
./vendor/bundle/ruby/2.3.0/gems/tw-1.2.0/lib/tw/client/stream.rb:16:in `user_stream'
exe/factorize-timeline.rb:81:in `block in <main>'
exe/factorize-timeline.rb:79:in `loop'
exe/factorize-timeline.rb:79:in `<main>'
2018-08-16 17:01:35 UTC: Retrying after 10 seconds
```



```
./vendor/bundle/ruby/2.3.0/gems/json-2.1.0/lib/json/common.rb:156:in `parse': 765: unexpected token at 'The Site Streams and User Streams endpoints have been turned off. Please migrate to alternate APIs. See https://t.co/usss' (JSON::ParserError)
	from ./vendor/bundle/ruby/2.3.0/gems/json-2.1.0/lib/json/common.rb:156:in `parse'
```
