require 'uri'
require 'net/http'

class LocationWeather
  CONDITIONS_ENDPOINT_URL = "https://api.tomorrow.io/v4/weather/realtime"

  INVALID_PARAMETERS_CODE = 400001
  BAD_REQUEST_STATUS = 400
  RATE_LIMITED_STATUS = 429
  SUCCESS_STATUS = 200

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
    @invalid_parameters = true
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
    check_response(current)

    current.body
  end

  def request_current_conditions
    Rails.cache.fetch(['weather','current',@zip_code].join('/'), expires_in: 30.minutes) do
        Rails.logger.info("Calling external API")

        @current_fetched = true
        url = URI(CONDITIONS_ENDPOINT_URL)
        wx_params = {
          'location' => @zip_code,
          'units' => @units,
          'apikey' => api_key
        }

        conn = Faraday.new(CONDITIONS_ENDPOINT_URL) do |f|
          f.request :json
          f.response :json
        end
        response = conn.get('', wx_params, { 'Accept' => 'application/json'})
        Rails.logger.info(response.status)
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
    elsif current.status == RATE_LIMITED_STATUS
      Rails.logger.error('Rate limiting in effect')
      @error = true
      @rate_limited = true
    elsif current.status == SUCCESS_STATUS
      @found = true
    else
      Rails.logger.error(response_body['type'])
      Rails.logger.error(response_body['message'])
      @error = true
    end
    Rails.logger.debug(current)
  end
end
