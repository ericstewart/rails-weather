require 'uri'
require 'net/http'

class WeatherController < ApplicationController
    def index
    end
    
    def results
        @realtime_fetched = false

        @realtime_results = current_weather(params)
        puts @realtime_results

        render partial: 'results'
    end

    private

    def current_weather(params)
        Rails.logger.info("Calling external API")
        @ealtime_fetched = true
        url = URI("https://api.tomorrow.io/v4/weather/realtime?location=#{params['zip']}&units=imperial&apikey=qX2IjL8zBwuDS7cAmL1yrOeqFf0FVnaH")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        request = Net::HTTP::Get.new(url)
        request["accept"] = 'application/json'

        response = http.request(request)
        JSON.parse(response.read_body)
    end
end
