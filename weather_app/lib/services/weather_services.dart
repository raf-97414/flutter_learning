import 'package:dio/dio.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/models/forecast_daily_model.dart';

/// Service for fetching weather data from Open-Meteo API
/// Handles current weather and forecast requests
class WeatherService {
  final Dio _dio;

  WeatherService(this._dio);

  /// Fetch current weather for given coordinates
  /// Returns WeatherModel with all current conditions
  Future<WeatherModel> fetchCurrentWeather(
    double latitude,
    double longitude, {
    String? cityName,
  }) async {
    try {
      // Build API URL with parameters
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': [
          'temperature_2m',
          'apparent_temperature',
          'weather_code',
          'relative_humidity_2m',
          'cloud_cover',
          'wind_speed_10m',
          'precipitation',
        ].join(','),
        'timezone': 'auto',
      });

      // Make request
      final response = await _dio.get(
        uri.toString(),
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch weather data');
      }

      // Parse response to WeatherModel
      return WeatherModel.fromJson(
        response.data as Map<String, dynamic>,
        cityName: cityName,
        isFromCache: false,
      );
    } catch (e) {
      throw Exception('Weather fetch error: $e');
    }
  }

  /// Fetch 7-day forecast for given coordinates
  /// Returns list of ForecastDailyModel (up to 7 days)
  Future<List<ForecastDailyModel>> fetchForecast(
    double latitude,
    double longitude,
  ) async {
    try {
      // Build API URL with daily parameters
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'daily': [
          'weather_code',
          'temperature_2m_max',
          'temperature_2m_min',
          'precipitation_sum',
          'precipitation_probability_max',
          'wind_speed_10m_max',
          'sunrise',
          'sunset',
          'uv_index_max',
        ].join(','),
        'timezone': 'auto',
        'forecast_days': '7',
      });

      // Make request
      final response = await _dio.get(
        uri.toString(),
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch forecast data');
      }

      final data = response.data as Map<String, dynamic>;
      final dailyData = data['daily'] as Map<String, dynamic>?;

      if (dailyData == null) {
        throw Exception('No daily forecast data available');
      }

      // Parse daily data to list of ForecastDailyModel
      return ForecastDailyModel.listFromJson(dailyData);
    } catch (e) {
      throw Exception('Forecast fetch error: $e');
    }
  }
}
