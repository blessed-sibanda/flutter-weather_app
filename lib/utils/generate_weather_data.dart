import 'dart:math' as math;

import 'package:weather_app/models/app_settings.dart' as settings;
import 'package:weather_app/models/app_settings.dart';
import 'package:weather_app/models/weather.dart';

/// This class has one purpose: to generate fake data.

class WeatherDataRepository {
  final DateTime _today = DateTime.now().toUtc();
  late DateTime startDateTime;
  late DateTime dailyDate;
  final _random = math.Random();
  List<City> cities = settings.allAddedCities;

  WeatherDataRepository() {
    startDateTime = DateTime.utc(_today.year, _today.month, _today.day, 0);
    dailyDate = _today;
  }

  int generateCloudCoverageNum(WeatherDescription description) {
    switch (description) {
      case WeatherDescription.cloudy:
        return 75;
      case WeatherDescription.rain:
        return 45;
      case WeatherDescription.clear:
      case WeatherDescription.sunny:
      default:
        return 5;
    }
  }

  WeatherDescription generateTimeAwareWeatherDescription(DateTime time) {
    final hour = time.hour;
    final isNightTime = (hour < 6 || hour > 18);
    const descriptions = WeatherDescription.values;

    // Used to generate a random weather description
    var description =
        descriptions.elementAt(_random.nextInt(descriptions.length));

    // Used to ensure that it isn't "sunny" at night time, and vice versa.
    if (isNightTime && description == WeatherDescription.sunny) {
      description = WeatherDescription.clear;
    }
    if (!isNightTime && description == WeatherDescription.clear) {
      description = WeatherDescription.sunny;
    }
    return description;
  }

  ForecastDay dailyForecastGenerator(City city, int low, int high) {
    List<Weather> forecasts = [];
    int runningMin = 555;
    int runningMax = -555;

    for (var i = 0; i < 8; i++) {
      startDateTime = startDateTime.add(const Duration(hours: 3));
      final temp = _random.nextInt(high);

      WeatherDescription randomDescription =
          generateTimeAwareWeatherDescription(startDateTime);

      final tempBuilder =
          Temperature(current: temp, temperatureUnit: TemperatureUnit.celsius);

      forecasts.add(
        Weather(
          city: city,
          dateTime: startDateTime,
          description: randomDescription,
          temperature: tempBuilder,
          cloudCoveragePercentage: generateCloudCoverageNum(randomDescription),
        ),
      );
    }

    final forecastDay = ForecastDay(
      hourlyWeather: forecasts,
      date: dailyDate,
      min: runningMin,
      max: runningMax,
    );

    dailyDate.add(const Duration(days: 1));
    return forecastDay;
  }

  Forecast getTenDayForecast(City city) {
    List<ForecastDay> tenDayForecast = [];

    List.generate(
      10,
      (index) => tenDayForecast.add(dailyForecastGenerator(city, 2, 10)),
    );

    return Forecast(city: city, days: tenDayForecast);
  }
}
