require 'uri'
require 'net/http'

class LocationWeather
  CONDITIONS_ENDPOINT_URL = "https://api.tomorrow.io/v4/weather/realtime"

  INVALID_PARAMETERS_CODE = 400001
  RATE_LIMITED_ERROR_CODE = 429

  attr_reader :zip_code, :current, :current_fetched, :units

  def initialize(zip_code)
    @zip_code = zip_code
    @current_fetched = false
    @units = 'imperial'
    @current = {}
    @forecast = {}
    @found = false
    @error = false
    @rate_limited = false
  end

  def found?
    !!@found
  end

  def error?
    !!@error
  end

  def rate_limited?
    !!@rate_limited
  end

  def fetch_current
    @current = query_current
  end

  private

  # Retrieve current conditions for a zip code.  Data may be cached but expected to be sufficiently recent.
  def query_current
    Rails.logger.info("Getting current weather for #{@zip_code}")
    current = Rails.cache.fetch(['weather','current',@zip_code].join('/'), expires_in: 30.minutes) do
        Rails.logger.info("Calling external API")

        @current_fetched = true
        url = URI(CONDITIONS_ENDPOINT_URL)
        wx_params = {
          'location' => @zip_code,
          'units' => @units,
          'apikey' => ENV['TOMORROW_API_KEY']
        }

        conn = Faraday.new(CONDITIONS_ENDPOINT_URL) do |f|
          f.request :json
          f.response :json
        end
        response = conn.get('', wx_params, { 'Accept' => 'application/json'})
        response.body
    end

    if current.dig('code') == INVALID_PARAMETERS_CODE
      Rails.logger.error(current.dig('type'))
      Rails.logger.error(current.dig('message'))
      @error = true
    elsif current.dig('code') == RATE_LIMITED_ERROR_CODE
      Rails.logger.error('Rate limiting in effect')
      @error = true
      @rate_limited = true
    else
      @found = true
    end
    Rails.logger.debug(current)
    current
  end
end
