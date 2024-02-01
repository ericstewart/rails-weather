class WeatherController < ApplicationController
    def index
    end

    def results
        @realtime_fetched = false

        @weather = LocationWeather.new(params['zip_code'])

        puts @realtime_results

        render partial: 'results'
    end

    private

    def current_weather(params)
    end
end
