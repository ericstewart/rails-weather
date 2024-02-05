require 'rails_helper'

RSpec.describe 'Weather', type: :request do
  describe 'GET /index' do
    it 'renders the index template' do
      get '/'
      expect(response.code).to eq('200')
      expect(response.body).to include('Weather for Location')
    end
  end

  let(:payload) do
    { 'data' =>
      { 'time' => '2024-02-03T02:47:00Z',
        'values' =>
          { 'cloudBase' => nil,
            'cloudCeiling' => nil,
            'cloudCover' => 9.03,
            'dewPoint' => 56.29,
            'freezingRainIntensity' => 0,
            'humidity' => 97.22,
            'precipitationProbability' => 0,
            'pressureSurfaceLevel' => 23.86,
            'rainIntensity' => 0,
            'sleetIntensity' => 0,
            'snowIntensity' => 0,
            'temperature' => 57.21,
            'temperatureApparent' => 57.21,
            'uvHealthConcern' => 0,
            'uvIndex' => 0,
            'visibility' => 5.05,
            'weatherCode' => 1000,
            'windDirection' => 21.81,
            'windGust' => 16.63,
            'windSpeed' => 8 } },
      'location' => { 'lat' => -1.2482616901397705, 'lon' => 36.68090057373047,
                      'name' => 'Kinoo ward, Kikuyu, 12345, Kiambu, Central Kenya, Kenya', 'type' => 'postcode' } }
  end

  let(:invalid_params_payload) do
    {
      'code' => 400_001,
      'type' => 'Invalid Query Parameters',
      'message' => "The entries provided as query parameters were not valid for the request. Fix parameters and try again: 'location' - failed to query by the term '9999999', try a different term"
    }
  end

  let(:rate_limited_payload) do
    {
      'code' => 429_001,
      'type' => 'Too Many Calls',
      'message' => 'The request limit for this resource has been reached for the current rate limit window. Wait and retry the operation, or examine your API request volume.'
    }
  end

  describe 'GET /weather_results' do
    it 'renders the results template' do
      stub_request(:get, 'https://api.tomorrow.io/v4/weather/realtime?apikey=testapikey&location=98753%20US&units=imperial')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Faraday v2.9.0'
          }
        )
        .to_return(status: 200, body: payload.to_json, headers: { 'Content-Type' => 'application/json' })

      get '/weather_results?zip_code=98753'

      expect(response.code).to eq('200')
      expect(response.body).to include('Weather at 98753')
    end

    it 'renders an alert when an invalid zip is passed' do
      stub_request(:get, 'https://api.tomorrow.io/v4/weather/realtime?apikey=testapikey&location=9999999%20US&units=imperial')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Faraday v2.9.0'
          }
        )
        .to_return(status: 400, body: invalid_params_payload.to_json, headers: { 'Content-Type' => 'application/json' })

      get '/weather_results?zip_code=9999999'

      expect(response.code).to eq('200')
      expect(response.body).to include('Oh no!')
      expect(response.body).to include('The zip-code \'9999999\' was not found.')
    end

    it 'renders an alert when no zip is passed' do
      get '/weather_results?zip_code='

      expect(response.code).to eq('200')
      expect(response.body).to include('Oh no!')
      expect(response.body).to include('The zip-code \'\' was not found.')
    end

    it 'renders an alert when data is unavailable due to rate limiting' do
      stub_request(:get, 'https://api.tomorrow.io/v4/weather/realtime?apikey=testapikey&location=12345%20US&units=imperial')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Faraday v2.9.0'
          }
        )
        .to_return(status: 429, body: rate_limited_payload.to_json, headers: { 'Content-Type' => 'application/json' })

      get '/weather_results?zip_code=12345'

      expect(response.code).to eq('200')
      expect(response.body).to include('Results are not available at this time due to too many requests.')
      expect(response.body).to include('Please try again later.')
    end

    it 'renders an error when an unexpected RuntimeError occurs' do
      stub_request(:get, 'https://api.tomorrow.io/v4/weather/realtime?apikey=testapikey&location=12345%20US&units=imperial')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Faraday v2.9.0'
          }
        )
        .to_raise(RuntimeError)

      get '/weather_results?zip_code=12345'

      expect(response.code).to eq('200')
      expect(response.body).to include('An error occurred')
      expect(response.body).to include('Please try again')
    end
  end
end
