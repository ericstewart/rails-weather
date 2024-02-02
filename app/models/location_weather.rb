require 'uri'
require 'net/http'

class LocationWeather

  CONDITIONS_ENDPOINT_URL = "https://api.tomorrow.io/v4/weather/realtime"

  attr_reader :zip_code, :current, :current_fetched, :units

  def initialize(zip_code)
    @zip_code = zip_code
    @current_fetched = false
    @units = 'imperial'
    @current = {}
    @forecast = {}

    fetch_current
  end

  private

  # Retrieve current conditions for a zip code.  Data may be cached but expected to be sufficiently recent.
  def fetch_current
    Rails.logger.info("Getting current weather for #{@zip_code}")
    @current = Rails.cache.fetch(['weather','current',@zip_code].join('/'), expires_in: 30.minutes) do
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

    Rails.logger.debug(@current)
    @current
  end
end
