module WeatherHelper

  # Return an appropriate temperature unit for the given system
  def temperature_units_for(unit_system)
    case unit_system
      when 'imperial'
        'F'
      when 'metric'
        'C'
    end
  end
end
