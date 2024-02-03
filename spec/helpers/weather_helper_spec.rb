require 'rails_helper'

RSpec.describe WeatherHelper, type: :helper do

  describe "#temperature_units_for" do
     it "reports F for imperial" do
       expect(helper.temperature_units_for('imperial')).to eq('F')
     end

     it "reports F for metric" do
       expect(helper.temperature_units_for('metric')).to eq('C')
     end

     it "returns nothing for nil system" do
       expect(helper.temperature_units_for('')).to eq('')
     end

     it "returns nothing for blank system" do
       expect(helper.temperature_units_for('')).to eq('')
     end

     it "returns nothing for unrecognized system" do
       expect(helper.temperature_units_for('invalid')).to eq('')
     end
  end
end
