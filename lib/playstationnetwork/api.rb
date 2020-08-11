require 'active_support/core_ext/hash'
require 'json'

module PlayStationNetwork

  MISSING_URL     ||= "'url' is missing from your configuration."
  MISSING_KEY     ||= "'key' is missing from your configuration."
  MISSING_SECRET  ||= "'secret' is missing from your configuration."

  # PlayStationNetwork.configure do |config|
  #   config.key = ''
  #   ..
  # end
  #
  def self.configure(&block)
    block.call(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.valid?
    return MISSING_URL    if configuration.url.nil?
    return MISSING_KEY    if configuration.key.nil?
    return MISSING_SECRET if configuration.secret.nil?
    true
  end

  class Configuration
    attr_writer :key, :secret, :url, :verify_ssl

    def key
      @key || ''
    end

    def secret
      @secret || ''
    end

    def url
      @url || 'https://happynation.co.uk/api'
    end

    def verify_ssl
      @verify_ssl
    end
  end

  class API
    require 'net/http'

    attr_accessor :options, :config

    CONFIG_ERROR ||= 'Please read the README.md on how to configure the PlayStationNetwork::API module.'

    def initialize(*options)
      raise CONFIG_ERROR unless PlayStationNetwork.valid?

      @config = PlayStationNetwork.configuration
      @options = {
        api_key: config.key,
        api_secret: config.secret,
        response_type: 'json'
      }
    end

  public

    # def get(url, dig_to = [])
    #   uri = URI.parse([config.url, url].join)

    #   Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
    #     request = Net::HTTP::Get.new(uri.request_uri)
    #     # request.set_form_data(options)

    #     response(http.request(request), dig_to)
    #   end
    # end

    def post(url, dig_to: [], xml: false)
      uri = URI.parse([config.url, url].join)

      Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https'), verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data(options)

        response(http.request(request), dig_to, xml)
      end
    end

  private

    def response(request, dig_to, xml)
      if request.code == '200'
        if xml
          body = parse_xml(request.body)
        else
          body = request.body
        end

        if dig_to.empty?
          JSON.parse(body, object_class: OpenStruct)
        else
          results = JSON.parse(body, object_class: OpenStruct).dig(*dig_to)
          results.pop if results&.last == 'Empty Node'
          return results
        end
      else
        raise "There was a problem parsing the JSON. Most likely an API problem: #{ request.code }"
      end
    end

    def parse_xml(response)
      xml_parsed = response
        .gsub('<?xml version=\"1.0\"?>', '')
        .gsub('<\/', '</')
        .tr('"', '')

      return Hash.from_xml(xml_parsed).to_json
    end
  end
end
