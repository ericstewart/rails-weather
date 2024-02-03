class WeatherController < ApplicationController
    def index
    end

    def results
        if params[:zip_code].present?
          @weather = LocationWeather.new(params[:zip_code])
          @weather.fetch_current
        end

        render partial: 'results'
    end
end
