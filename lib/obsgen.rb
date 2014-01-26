require 'thor'
require 'json'
require 'open4'
require 'random-location'

module Obsgen

  def self.lat
    41.38506
  end

  def self.lng
    2.17340
  end

  def self.radius
    10000
  end

  def self.random_observation
    { 'action' => ['add', 'delete'].sample, 'coord' => RandomLocation.near_by(lat, lng, radius), 'value' => Random.new.rand(2) }
  end

  class CLI < Thor
    desc "publish EXCHANGE", "publish random observations to EXCHANGE"
    option :verbose
    def publish(exchange)
      payload = "#{Obsgen::random_observation.to_json}"
      cmd = "rabbitmqadmin publish exchange=#{exchange} routing_key='' payload='#{payload}'"

      pid, stdin, stdout, stderr = Open4::popen4(cmd)
      stderr = stderr.read

      unless stderr == '\n' || stderr == '' || stderr.nil?
        $stderr.puts stderr
      end
      $stdout.puts payload if options[:verbose]
    end
  end

end
