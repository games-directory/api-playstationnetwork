module PlayStationNetwork
  class Game < PlayStationNetwork::API
    GAMES_PARAMETERS_TYPES ||= ['all', 'ps4', 'ps3', 'psp2', 'psvita']

    INVALID_NPCOMMID_TYPE  ||= "'npcommid' parameter needs to be a String"
    INVALID_PLATFORM_TYPE  ||= "'platform' parameter needs to be a String and one of #{ GAMES_PARAMETERS_TYPES.join(', ') }"
    INVALID_POPULAR_TYPE   ||= "'popular' parameter needs to be a Boolean"

    def initialize(npcommid = '')
      raise INVALID_NPCOMMID_TYPE unless npcommid.is_a?(String)

      super
      unless npcommid.empty?
        options[:npcommid] = npcommid
      end
    end

    def details
      post('/psnGetGame')
    end

    def trophies
      post('/psnGetTrophies')
    end

    def all(platform: 'all', popular: false)
      raise INVALID_PLATFORM_TYPE unless platform.is_a?(String)
      raise INVALID_PLATFORM_TYPE unless GAMES_PARAMETERS_TYPES.include?(platform)
      raise INVALID_POPULAR_TYPE unless popular.is_a?(FalseClass) || popular.is_a?(TrueClass)

      if popular
        options[:list] = platform
        url = '/psnPopularThisWeek'
      else
        options[:platform] = platform
        url = '/psnListGames'
      end

      post(url, dig_to: ['psn_api', 'game'], xml: true)
    end
  end
end