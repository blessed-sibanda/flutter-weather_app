import 'package:weather_app/models/app_settings.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/utils/generate_weather_data.dart';

class ForecastController {
  City city;
  Forecast? forecast;
  ForecastDay? selectedDay;
  Weather? selectedHourlyTemperature;
  final DateTime _today = DateTime.now();
  final WeatherDataRepository _repository = WeatherDataRepository();

  ForecastController(this.city) {
    init();
  }

  init() {
    forecast = _repository.getTenDayForecast(city);
    selectedDay = Forecast.getSelectedDayForecast(
      forecast!,
      DateTime(_today.year, _today.month, _today.day),
    );
    selectedHourlyTemperature = ForecastDay.getWeatherForHour(
      selectedDay!,
      DateTime.now().toLocal().hour,
    );
  }
}
