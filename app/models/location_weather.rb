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

    @current, @forecast = Rails.cache.fetch(['weather','current',@zip_code].join('/'), expires_in: 30.minutes.to_i) do
        Rails.logger.info("Calling external API")

        @current_fetched = true
        url = URI(CONDITIONS_ENDPOINT_URL + "?location=#{@zip_code}&units=#{@units}&apikey=#{ENV['TOMORROW_API_KEY']}")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        request = Net::HTTP::Get.new(url)
        request["accept"] = 'application/json'

        response = http.request(request)
        response_json = JSON.parse(response.read_body)
        response_json
    end

    Rails.logger.debug(@current)
    @current
  end
end
