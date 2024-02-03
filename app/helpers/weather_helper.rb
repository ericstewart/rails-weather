module WeatherHelper

  SYSTEM_TEMPERATURE_UNITS = {
    'imperial' => 'F',
    'metric' => 'C'
  }


  # Return an appropriate temperature unit for the given system
  def temperature_units_for(unit_system)
    SYSTEM_TEMPERATURE_UNITS[unit_system] || ''
  end

  def display_for_weather_code(weather_code)
    LocationWeather::WEATHER_CODES[weather_code]
  end
end
