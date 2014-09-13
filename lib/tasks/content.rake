namespace :content do
  desc "TODO"
  task fill: :environment do
    require 'rss'
    require 'open-uri'
    require 'rest_client'

    url = 'https://news.ycombinator.com/rss'
    cache = {}

    def get_data url
      token = 'f7c04f2341edcc9393bb6b388e61a13f09ab5336'
      JSON.parse RestClient.get('https://readability.com/api/content/v1/parser', {:params => {:url => url, :token => token}})
    end

    def translate text
      yandex_api_key = 'trnsl.1.1.20140913T111229Z.358a605994004545.7cdd6d651b2dabe4550deb1262b108e6cf965846'
      result = JSON.parse(RestClient.get 'https://translate.yandex.net/api/v1.5/tr.json/translate', {:accept => :json, :params => {:key => yandex_api_key, :text => text, :lang => 'en-ru', :format => 'html'}})
      text = result['text']
      text.size == 1 ? text.first : text
    end

    def valid_url url
      !url.include?('[pdf]')
    end

    open(url) do |rss|
      feed = RSS::Parser.parse(rss)
      puts "Title: #{feed.channel.title}"
      feed.items.each do |item|
        next unless valid_url(item.title)
        next if Monologue::Post.exists?(:origin => item.link)
        puts "Item: #{item.title}, #{item.link}"

        unless cache[item.link]
          begin
            data = get_data item.link
            content = translate data['content']
            title = translate data['title']
          rescue
            puts "Касяк #{item.link}"
            next
          end

          Monologue::Post.create(:origin => item.link, :title => title, :published_at => DateTime.now, :user_id => 1, :content => content, :published => true)
        end
      end
    end

  end

end
