module PlayStationNetwork
  class User < PlayStationNetwork::API
    INVALID_IDENTITY_TYPE ||= "'identity' parameter needs to be a String"
    INVALID_NPCOMMID_TYPE ||= "'npcommid' parameter needs to be a String"

    def initialize(identity)
      raise INVALID_IDENTITY_TYPE unless identity.is_a?(String)

      super

      options[:user_id] = identity
    end

    def profile
      post('/psnGetUser')
    end

    def games(dig_to: ['games'])
      post('/psnGetUserGames', dig_to)
    end

    def trophies(npcommid, dig_to: ['trophies'])
      raise INVALID_IDENTITY_TYPE unless npcommid.is_a?(String)

      options[:npcommid] = npcommid
      post('/psnGetUserTrophies', dig_to)
    end
  end
end