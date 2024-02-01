require 'rails_helper'

RSpec.describe LocationWeather, type: :model do
  subject { LocationWeather.new(12345) }

  it 'indicates which zip code is in effect' do
    expect(subject.zip_code).to eq(12345)
  end
end
