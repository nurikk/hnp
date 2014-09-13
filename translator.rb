require 'rubygems'
require 'rss'
require 'open-uri'
require 'pry'
require 'json'
require 'yandex-translator'


Yandex::Translator.set_api_key('trnsl.1.1.20140913T111229Z.358a605994004545.7cdd6d651b2dabe4550deb1262b108e6cf965846')


url = 'https://news.ycombinator.com/rss'
cache = {}

def get_data url
  token = 'f7c04f2341edcc9393bb6b388e61a13f09ab5336'
  JSON.parse open("https://readability.com/api/content/v1/parser?url=#{url}&token=#{token}").read
end

def translate text
  'https://translate.yandex.net/api/v1.5/tr.json'
end




open(url) do |rss|
  feed = RSS::Parser.parse(rss)
  puts "Title: #{feed.channel.title}"
  feed.items.each do |item|
    puts "Item: #{item.title}, #{item.link}"

    unless cache[item.link]
      data = get_data item.link

      text = Yandex::Translator.translate data['content'], 'ru'
      binding.pry
    end
  end
end
