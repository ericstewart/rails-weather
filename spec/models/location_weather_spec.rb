require 'rails_helper'

RSpec.describe LocationWeather, type: :model do
  subject { LocationWeather.new(12_345) }

  context 'when proper results are returned' do
    before(:each) do
      stub_request(:get, 'https://api.tomorrow.io/v4/weather/realtime?apikey=testapikey&location=12345%20US&units=imperial')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Faraday v2.9.0'
          }
        )
        .to_return(status: 200, body: '{"data": {"date": "12345"}}', headers: { 'Content-Type' => 'application/json' })
      subject.fetch_current
    end

    it 'indicates which zip code is in effect' do
      expect(subject.zip_code).to eq(12_345)
    end

    it 'returns a result hash for the location' do
      expect(subject.current).to be_a(Hash)
    end

    it 'does not indicate an error' do
      expect(subject.error?).to be_falsey
    end
  end

  context 'error handling' do
    subject { LocationWeather.new(9_999_999) }

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

    it 'indicates when the zip code was not found' do
      stub_request(:get, 'https://api.tomorrow.io/v4/weather/realtime?apikey=testapikey&location=9999999%20US&units=imperial')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Faraday v2.9.0'
          }
        )
        .to_return(status: 400, body: invalid_params_payload.to_json, headers: { 'Content-Type' => 'application/json' })

      subject.fetch_current
      expect(subject.error?).to be_truthy
      expect(subject).not_to be_found
      expect(subject.current).to be_a(Hash)
    end

    it 'indicates when rate limiting is in effect' do
      stub_request(:get, 'https://api.tomorrow.io/v4/weather/realtime?apikey=testapikey&location=9999999%20US&units=imperial')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Faraday v2.9.0'
          }
        )
        .to_return(status: 429, body: rate_limited_payload.to_json, headers: { 'Content-Type' => 'application/json' })

      expect { subject.fetch_current }.to raise_error(LocationWeather::RateLimitError)
    end
  end
end
