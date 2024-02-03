class WeatherController < ApplicationController
rescue_from RuntimeError, with: :error_result
    def index
    end

    def results
        if params[:zip_code].present?
          @weather = LocationWeather.new(params[:zip_code])
          @weather.fetch_current
        end

        render partial: 'results'
    end

    private

    def error_result
        render partial: 'error_results'
    end
end
