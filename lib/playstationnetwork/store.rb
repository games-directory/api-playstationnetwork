module PlayStationNetwork
  class Store
    require 'net/http'

    attr_reader :args, :region, :language, :headers

    def initialize(args, region: 'GB', language: 'en')
      @args = args
      @region = region
      @language = language

      @headers = {
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36",
        "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
        "Authority" => "store.playstation.com"
      }
    end

    def search(game_type = 'PSN Game')
      raise '' unless game_type != 'PSN Game' || game_type != 'Bundle'
      games = []

      options = {
        query: {
          suggested_size: 5,
          mode: 'game'
        }
      }

      uri = URI.parse(search_url(args))
      uri.query = URI.encode_www_form(options[:query])

      Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
        request = Net::HTTP::Get.new(uri.request_uri)

        headers.each do |key, value|
          request[key] = value
        end

        response = http.request(request)
        
        if response.code == '200'
          results = JSON.parse(response.body)['included'].select do |result|
            result['attributes']['game-content-type'] == game_type
          end

          results.map { |r| r.deep_transform_keys(&:underscore) }.each do |result|
            games << {
              store_id:     result['id'],
              name:         result['attributes']['name'],
              description:  result['attributes']['long_description'],
              type:         result['type'],
              raw:          result
            }
          end

          return JSON.parse(games.to_json, object_class: OpenStruct)
        else
          raise response.code
        end
      end
    end

    def details
      uri = URI.parse(details_url(args))

      Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
        request = Net::HTTP::Get.new(uri.request_uri)

        headers.each do |key, value|
          request[key] = value
        end

        response = http.request(request)
        
        if response.code == '200'
          return JSON.parse(
            JSON.parse(response.body)
              .deep_transform_keys(&:underscore)
              .to_json,

            object_class: OpenStruct
          )
        else
          raise response.code
        end
      end
    end

  private

    def search_url(query)
      "https://store.playstation.com/valkyrie-api/#{ language }/#{ region }/19/tumbler-search/#{ URI.encode(query) }"
    end

    def details_url(identifier)
      "https://store.playstation.com/store/api/chihiro/00_09_000/container/#{ region }/#{ language }/19/#{ identifier }"
    end

    def deep_transform_keys(object, &block)
      case object
      when Hash
        object.each_with_object({}) do |(key, value), result|
          result[yield(key)] = deep_transform_keys(value, &block)
        end
      when Array
        object.map { |e| deep_transform_keys(e, &block) }
      else
        object
      end
    end
  end
end