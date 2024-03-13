# frozen_string_literal: true

# Primary Rails controller for Querying of weather reports
class WeatherController < ApplicationController
  WEATHER_FIELDS = [
    ['temperature', 'Temperature', '°F'],
    ['temperatureApparent', 'Feels Like', '°F'],
    ['dewPoint', 'Dew Point', '°F'],
    ['humidity', 'Humidity', '%'],
    ['windSpeed', 'Wind Speed', 'mph'],
    ['windDirection', 'Wind Direction', 'degrees'],
    ['windGust', 'Window Gust', 'mph'],
    ['visibility', 'Visibility', 'mi'],
    ['cloudCover', 'Cloud Cover', 'mi']
  ].freeze

  rescue_from RuntimeError, with: :error_result

  def index; end

  def results
    @weather = fetch_weather if params[:zip_code].present?

    if @weather&.found?
      set_weather_fields
      render partial: 'results'
    else
      render partial: 'not_found'
    end
  rescue LocationWeather::RateLimitError
    render partial: 'too_many_requests'
  rescue LocationWeather::WeatherApiError
    render partial: 'error_results'
  end

  private

  # Handling rendering of an error response
  def error_result
    render partial: 'error_results'
  end

  # Set the field data for display
  def set_weather_fields
    @weather_fields = WEATHER_FIELDS
  end

  # Retrieve weather data from our data sources and set
  def fetch_weather
    Rails.logger.info("weather_request:#{params[:zip_code]}")

    weather = LocationWeather.new(params[:zip_code].strip)
    weather.fetch_current
    weather
  end
end
