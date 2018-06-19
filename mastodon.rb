require 'nokogiri'
require 'open-uri'
require 'rmagick'

class MastodonAPI

    def initialize(client)
        @client = client
        @timeline = Hash.new
        @avatar = Array.new
        @media_id = nil
    end

    def MediaUpload(file_path)

        if file_path != nil then
            @media_id = @client.upload_media(file_path).id
        else
            @media_id = nil
        end
    end

    def Toot(message, visibility, sensitive, spoiler_text)
        message += "\n #Legion"
        response = @client.create_status(message.encode("UTF-8"), :media_ids => @media_id, :visibility => visibility, :sensitive => sensitive, :spoiler_text => spoiler_text)
    end
end

class MastodonStreaming

    def initialize(stream)
        @stream = stream
    end

    def HomeTimeline(window)
        @stream.user() do |toot|
            message = Nokogiri::HTML.parse(toot.content, nil, nil).search('p')
            return message.text
        end
    end

    def PublicTimeline(window)
        @stream.firehose() do |toot|
            message = Nokogiri::HTML.parse(toot.content, nil, nil).search('p')
            return message.text
        end
    end

    def LocalTimeline(window)
        @stream.firehose() do |toot|
            if toot.uri.to_s =~ /#{ENV['MASTODON_URL'].to_s}/ then
                message = Nokogiri::HTML.parse(toot.content, nil, nil).search('p')
                return message.text
            end
        end
    end
end