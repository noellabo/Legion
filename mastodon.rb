require 'nokogiri'
require 'open-uri'
require 'rmagick'

class MastodonAPI

    def initialize(client)
        @client = client
        @timeline = Hash.new
        @avatar = Array.new
    end

    def Toot(message)
        message += "\n #Legion"
        response = @client.create_status(message.encode("UTF-8"))
    end

    def GetAvatar(url)
        open(url) {|f|
            File.open("avatar/avatar.png","wb") do |file|
                file.puts f.read
            end
        }
        Magick::ImageList.new("avatar/avatar.png").resize(30, 30).write("avatar/avatar.png")

        Sprite.new(20, 20, Image.load("avatar/avatar.png"))
    end

    def GetHomeTimeline
        i = 0

        @client.home_timeline.each do |toot|
            @timeline[i] = toot
            i += 1
        end
    end

    def DrawHomeTimeline
        for num in 0..5

            toot = Nokogiri::HTML.parse(@timeline[num].content, nil, nil).search('p')
            toot.text.gsub!(/<br>/, "\n")

            @avatar[num] = GetAvatar("#{@timeline[num].account.avatar}")
            @avatar[num].x, @avatar[num].y = 0, 60 * num + 10
            @avatar[num].draw

            Window.draw_font(0, 60 * num + 45, toot.text.length > 40 ? "#{toot.text[0..40]}……" : "#{toot.text}", @font)
        end
    end
end