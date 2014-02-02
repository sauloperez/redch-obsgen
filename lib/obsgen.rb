require 'thor'
require 'json'
require 'open4'
require 'random-location'

module Obsgen

  class CLI < Thor

    desc "publish EXCHANGE", "publish random observations to EXCHANGE"
    option :verbose
    def publish(exchange)
      payload = "#{CLI.random_observation.to_json}"
      CLI.publish_to_exchange(payload, exchange)

      puts "#{payload}" if options[:verbose]
    end

    def self.lat
      41.38506
    end

    def self.lng
      2.17340
    end

    def self.radius
      10000
    end

    def self.coordinates
      @@coordinates ||= []
      @@coordinates
    end

    def self.coordinates=(coordinates)
      @@coordinates = coordinates
    end

    def self.pick_coord(action)
      if action == 'delete'
        coordinates.shift
      else
        coord = RandomLocation.near_by(lat, lng, radius)
        coordinates << coord
        coord
      end
    end

    def self.random_observation(action = ['add', 'delete'].sample)
      { 'action' => action, 'coord' => pick_coord(action), 'value' => rand }
    end

    def self.publish_to_exchange(payload, exchange)
      cmd = "rabbitmqadmin publish exchange=#{exchange} routing_key='' payload='#{payload}'"
      pid, stdin, stdout, stderr = Open4::popen4(cmd)
      [stdout.read, stderr.read]
    end
  end

end
