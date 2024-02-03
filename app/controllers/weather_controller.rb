class WeatherController < ApplicationController
rescue_from RuntimeError, with: :error_result
    def index
    end

    def results
        if params[:zip_code].present?
          @weather = LocationWeather.new(params[:zip_code].strip)
          @weather.fetch_current
        end

        if !@weather&.found?
            render partial: 'not_found'
        else
            render partial: 'results'
        end

    rescue LocationWeather::RateLimitError
        render partial: 'too_many_requests'
    rescue LocationWeather::WeatherApiError
        render partial: 'error_results'
    end

    private

    def error_result
        render partial: 'error_results'
    end
end
