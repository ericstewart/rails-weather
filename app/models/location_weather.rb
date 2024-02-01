require 'uri'
require 'net/http'

class LocationWeather
  attr_reader :zip_code, :current_fetched

  def initialize(zip_code)
    @zip_code = zip_code
    @current_fetched = false
    @units = 'imperial'
  end

  # Retrieve current conditions for a zip code.  Data may be cached but expected to be sufficiently recent.
  def current
    Rails.logger.info("Getting current weather for #{@zip_code}")

    @realtime_results ||= Rails.cache.fetch( ['weather', 'realtime',zip_code].join('/'), expires_in: 30.minutes.to_i) do
        Rails.logger.info("Calling external API")

        @current_fetched = true
        url = URI("https://api.tomorrow.io/v4/weather/realtime?location=#{@zip_code}&units=#{@units}&apikey=qX2IjL8zBwuDS7cAmL1yrOeqFf0FVnaH")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        request = Net::HTTP::Get.new(url)
        request["accept"] = 'application/json'

        response = http.request(request)
        JSON.parse(response.read_body)
    end

    @realtime_results
  end
end
