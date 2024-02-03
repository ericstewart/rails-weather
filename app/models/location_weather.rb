require 'uri'
require 'net/http'

class LocationWeather
  WeatherApiError = Class.new(StandardError)
  RateLimitError = Class.new(StandardError)

  CONDITIONS_ENDPOINT_URL = "https://api.tomorrow.io/v4/weather/realtime"

  INVALID_PARAMETERS_CODE = 400001
  BAD_REQUEST_STATUS = 400
  RATE_LIMITED_STATUS = 429
  SUCCESS_STATUS = 200

  WEATHER_CODES = {
    1000 => 'Clear',
    1100 => 'Mostly Clear',
    1101 => 'Partly Cloudy',
    1102 => 'Mostly Cloudy',
    1001 => 'Cloudy',
    2100 => 'Light Fog',
    2101 => 'Fog',
    4000 => 'Drizzle',
    4200 => 'Light Rain',
    4001 => 'Rain',
    4201 => 'Heavy Rain',
    5001 => 'Heavy Snow',
    6000 => 'Freezing Drizzle',
    6200 => 'Light Freezing Drizzle',
    6001 => 'Freezing Rain',
    6201 => 'Heavy Freezing Rain',
    7102 => 'Light Ice Pellets',
    7000 => 'Ice Pellets',
    7101 => 'Heavy Ice Pellets',
    8000 => 'Thunderstorm'
  }

  attr_reader :zip_code, :current, :current_fetched, :units

  def initialize(zip_code)
    @zip_code = zip_code
    @current_fetched = false
    @units = 'imperial'
    @current = {}
    @forecast = {}
    @found = false
    @error = false
    @invalid_parameters = true
  end

  def found?
    !!@found
  end

  def error?
    !!@error
  end

  def invalid_parameters?
    !!@invalid_parameters
  end

  def fetch_current
    @current = query_current
  end

  private

  def api_key
    Rails.env.test? ? 'testapikey' : ENV['TOMORROW_API_KEY']
  end

  def query_current
    Rails.logger.info("Getting current weather for #{@zip_code}")
    current = request_current_conditions
    return nil unless current

    check_response(current)

    current.body
  end

  def request_current_conditions
    Rails.cache.fetch(['weather','current',@zip_code].join('/'), expires_in: 30.minutes) do
        Rails.logger.info("Calling external API")

        @current_fetched = true
        url = URI(CONDITIONS_ENDPOINT_URL)
        wx_params = {
          'location' => "#{@zip_code} US",
          'units' => @units,
          'apikey' => api_key
        }

        conn = Faraday.new(CONDITIONS_ENDPOINT_URL) do |f|
          f.request :json
          f.response :json
        end
        response = conn.get('', wx_params, { 'Accept' => 'application/json'})

        # Ideally, we only want to cache responses that shouldn't be retried immediately.
        # Bad requests that result from locations not found, for example, could be cached
        # so that we don't try them again anytime soon. Other errors, such as rate limits
        # are temporary.
        if response.status == BAD_REQUEST_STATUS
          raise WeatherApiError unless response.body['code'] == INVALID_PARAMETERS_CODE
        end
        raise RateLimitError if response.status == RATE_LIMITED_STATUS
        raise WeatherApiError if is_error_status?(response.status)

        response
    end
  end

  # Determine what happened so that clients of this class have feedback
  def check_response(current)
    response_body = current.body
    if current.status == BAD_REQUEST_STATUS && response_body['code'] == INVALID_PARAMETERS_CODE
      Rails.logger.error(response_body['type'])
      Rails.logger.error(response_body['message'])
      @invalid_parameters = true
      @error = true
    elsif current.status == SUCCESS_STATUS
      @found = true
    else
      Rails.logger.error(response_body['type'])
      Rails.logger.error(response_body['message'])
      @error = true
    end
    Rails.logger.debug(current)
  end

  def is_error_status?(status_code)
     status_code.in?([401, 403, 404, 500])
  end
end
