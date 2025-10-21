import 'package:hive/hive.dart';
import 'package:weather_app/utils/weather_code_mapper_util.dart';

/// Represents current weather data
/// Immutable model for real-time weather information from Open-Meteo API
@HiveType(typeId: 0)
class WeatherModel {
  /// City name
  @HiveField(0)
  final String cityName;

  /// Current temperature (Celsius)
  @HiveField(1)
  final double temperature;

  /// Apparent/feels-like temperature (Celsius)
  @HiveField(2)
  final double? apparentTemperature;

  /// WMO weather code (0-99)
  @HiveField(3)
  final int weatherCode;

  /// Relative humidity (0-100%)
  @HiveField(4)
  final int? humidity;

  /// Cloud cover percentage (0-100%)
  @HiveField(5)
  final int? cloudCover;

  /// Wind speed (km/h)
  @HiveField(6)
  final double windSpeed;

  /// Current precipitation (mm)
  @HiveField(7)
  final double precipitation;

  /// Latitude coordinate
  @HiveField(8)
  final double latitude;

  /// Longitude coordinate
  @HiveField(9)
  final double longitude;

  /// When this data was fetched
  @HiveField(10)
  final DateTime timestamp;

  /// Whether this came from cache
  @HiveField(11)
  final bool isFromCache;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    this.apparentTemperature,
    required this.weatherCode,
    this.humidity,
    this.cloudCover,
    required this.windSpeed,
    required this.precipitation,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.isFromCache,
  });

  // ============================================================================
  // COMPUTED PROPERTIES (Getters)
  // ============================================================================

  /// Get human-readable condition name
  String get condition => WeatherCodeMapperUtil.getConditionName(weatherCode);

  /// Get detailed weather description
  String get description =>
      WeatherCodeMapperUtil.getDescriptionName(weatherCode);

  /// Get weather icon - returns Icon widget with size 24
  dynamic get iconData =>
      WeatherCodeMapperUtil.getIconForCode(weatherCode, {}, size: 24);

  /// Check if cached data has expired (> 15 minutes old)
  bool get isExpired => DateTime.now().difference(timestamp).inMinutes > 15;

  // ============================================================================
  // JSON SERIALIZATION
  // ============================================================================

  /// Convert to Map for Hive caching
  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'apparentTemperature': apparentTemperature,
      'weatherCode': weatherCode,
      'humidity': humidity,
      'cloudCover': cloudCover,
      'windSpeed': windSpeed,
      'precipitation': precipitation,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'isFromCache': isFromCache,
    };
  }

  /// Parse from API response
  factory WeatherModel.fromJson(
    Map<String, dynamic> json, {
    String? cityName,
    bool isFromCache = false,
  }) {
    final current = json['current'] as Map<String, dynamic>?;

    if (current == null) {
      throw Exception('Missing "current" data in weather response.');
    }

    // Extract temperature (required)
    final temperature = (current['temperature_2m'] as num?)?.toDouble();
    if (temperature == null) {
      throw Exception('Missing temperature data.');
    }

    // Extract weather code (required)
    final weatherCode = current['weather_code'] as int?;
    if (weatherCode == null) {
      throw Exception('Missing weather code.');
    }

    // Extract optional fields with defaults
    final apparentTemp = (current['apparent_temperature'] as num?)?.toDouble();
    final humidity = (current['relative_humidity_2m'] as num?)?.toInt();
    final cloudCover = (current['cloud_cover'] as num?)?.toInt();
    final windSpeed = (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0;
    final precipitation = (current['precipitation'] as num?)?.toDouble() ?? 0.0;

    // Extract coordinates
    final latitude = (json['latitude'] as num?)?.toDouble() ?? 0.0;
    final longitude = (json['longitude'] as num?)?.toDouble() ?? 0.0;

    // Use provided city name or fallback
    final finalCityName = cityName ?? 'Unknown Location';

    return WeatherModel(
      cityName: finalCityName,
      temperature: temperature,
      apparentTemperature: apparentTemp,
      weatherCode: weatherCode,
      humidity: humidity,
      cloudCover: cloudCover,
      windSpeed: windSpeed,
      precipitation: precipitation,
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      isFromCache: isFromCache,
    );
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  @override
  String toString() {
    return 'WeatherModel('
        'city: $cityName, '
        'temp: ${temperature.round()}°C, '
        'condition: $condition'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeatherModel &&
        other.cityName == cityName &&
        other.temperature == temperature &&
        other.weatherCode == weatherCode;
  }

  @override
  int get hashCode => Object.hash(cityName, temperature, weatherCode);

  /// Create a copy with some fields modified
  WeatherModel copyWith({
    String? cityName,
    double? temperature,
    double? apparentTemperature,
    int? weatherCode,
    int? humidity,
    int? cloudCover,
    double? windSpeed,
    double? precipitation,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    bool? isFromCache,
  }) {
    return WeatherModel(
      cityName: cityName ?? this.cityName,
      temperature: temperature ?? this.temperature,
      apparentTemperature: apparentTemperature ?? this.apparentTemperature,
      weatherCode: weatherCode ?? this.weatherCode,
      humidity: humidity ?? this.humidity,
      cloudCover: cloudCover ?? this.cloudCover,
      windSpeed: windSpeed ?? this.windSpeed,
      precipitation: precipitation ?? this.precipitation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}
