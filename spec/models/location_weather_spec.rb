require 'rails_helper'

RSpec.describe LocationWeather, type: :model do
  subject { LocationWeather.new(12345) }

  context "when proper results are returned" do
  before(:each) do
    stub_request(:get, "https://api.tomorrow.io/v4/weather/realtime?apikey=qX2IjL8zBwuDS7cAmL1yrOeqFf0FVnaH&location=12345&units=imperial").
         with(
           headers: {
          'Accept'=>'application/json',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Faraday v2.9.0'
           }).
         to_return(status: 200, body: '{"data": {"date": "12345"}}', headers: { 'Content-Type' => 'application/json'})
  end

  it 'indicates which zip code is in effect' do
    expect(subject.zip_code).to eq(12345)
  end

  it 'returns a result hash for the location' do
    expect(subject.current).to be_a(Hash)
  end
end

  context "error handling" do
    subject { LocationWeather.new(9999999) }

    it 'indicates when the zip code was not found' do
      stub_request(:get, "https://api.tomorrow.io/v4/weather/realtime?apikey=qX2IjL8zBwuDS7cAmL1yrOeqFf0FVnaH&location=9999999&units=imperial").
           with(
             headers: {
            'Accept'=>'application/json',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Faraday v2.9.0'
             }).
           to_return(status: 200, body: '{"code": 400001, "type": "Invalid Query Parameters", "message": "The entries provided as query parameters were not valid for the request. Fix parameters and try again: \'location\' - failed to query by the term \'9999999\', try a different term"}', headers: { 'Content-Type' => 'application/json'})


      expect(subject).not_to be_found
      expect(subject.current).to be_a(Hash)
    end
  end
end
