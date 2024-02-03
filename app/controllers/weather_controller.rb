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
            set_weather_fields
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

    def set_weather_fields
      @weather_fields = [
        ['temperature', 'Temperature', '°F'],
        ['temperatureApparent', 'Feels Like', '°F'],
        ['dewPoint', 'Dew Point', '°F'],
        ['humidity', 'Humidity', '%'],
        ['windSpeed', 'Wind Speed', 'mph'],
        ['windDirection', 'Wind Direction', 'degrees'],
        ['windGust', 'Window Gust', 'mph'],
        ['visibility', 'Visibility', 'mi'],
        ['cloudCover', 'Cloud Cover', 'mi']
      ]
    end
end
