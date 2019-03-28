require 'playstationnetwork/version'

module PlayStationNetwork
  Dir[File.dirname(__FILE__) + '/playstationnetwork/*.rb'].each do |file|
    require file
  end
end
