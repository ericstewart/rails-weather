module WeatherHelper

  def display_for_weather_code(weather_code)
    LocationWeather::WEATHER_CODES[weather_code]
  end
end
