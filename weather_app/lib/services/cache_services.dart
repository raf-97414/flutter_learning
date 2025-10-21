import 'package:hive/hive.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/models/forecast_daily_model.dart';

/// Service for caching weather data locally using Hive
/// Provides persistent storage with expiration logic
/// Reduces API calls and enables offline functionality
class CacheServices {
  /// Box name for current weather data
  static const String _weatherBoxName = 'weather_cache';

  /// Box name for forecast data
  static const String _forecastBoxName = 'forecast_cache';

  /// Key for storing current weather in box
  static const String _currentWeatherKey = 'current_weather';

  /// Key for storing forecast list in box
  static const String _forecastKey = 'forecast_data';

  /// Key for storing weather timestamp
  static const String _weatherTimestampKey = 'weather_timestamp';

  /// Key for storing forecast timestamp
  static const String _forecastTimestampKey = 'forecast_timestamp';

  /// Cache validity duration for current weather (15 minutes)
  static const Duration _weatherCacheValidity = Duration(minutes: 15);

  /// Cache validity duration for forecast (1 hour)
  static const Duration _forecastCacheValidity = Duration(hours: 1);

  /// Hive box for current weather storage
  Box? _weatherBox;

  /// Hive box for forecast storage
  Box? _forecastBox;

  Future<void> init() async {
    try {
      // Open both boxes
      _weatherBox = await Hive.openBox(_weatherBoxName);
      _forecastBox = await Hive.openBox(_forecastBoxName);

      print('Cache service initialized successfully');
    } catch (e) {
      print('Error initializing cache service: $e');
      rethrow;
    }
  }

  /// Check if cache service is initialized
  bool get isInitialized => _weatherBox != null && _forecastBox != null;

  /// Save current weather to cache
  /// Stores both weather data and timestamp
  Future<void> saveCurrentWeather(WeatherModel weather) async {
    try {
      // Guard: Check initialization
      if (_weatherBox == null) {
        throw Exception('Cache service not initialized. Call init() first.');
      }

      // Convert to JSON map for storage
      final weatherJson = weather.toJson();

      // Save weather data
      await _weatherBox!.put(_currentWeatherKey, weatherJson);

      // Save timestamp
      await _weatherBox!.put(
        _weatherTimestampKey,
        DateTime.now().toIso8601String(),
      );

      print('Current weather cached: ${weather.cityName}');
    } catch (e) {
      print('Error saving weather to cache: $e');
      rethrow;
    }
  }

  /// Retrieve current weather from cache
  /// Returns null if no cached data exists
  /// Does NOT check validity - use isCurrentWeatherValid() for that
  Future<WeatherModel?> getCurrentWeather() async {
    try {
      // Guard: Check initialization
      if (_weatherBox == null) {
        throw Exception('Cache service not initialized');
      }

      // Get cached JSON
      final weatherJson = _weatherBox!.get(_currentWeatherKey);

      if (weatherJson == null) {
        print('No cached weather found');
        return null;
      }

      // Parse JSON to model
      final weather = WeatherModel.fromJson(
        Map<String, dynamic>.from(weatherJson as Map),
        isFromCache: true,
      );

      print('Retrieved cached weather: ${weather.cityName}');
      return weather;
    } catch (e) {
      print('Error retrieving cached weather: $e');
      return null;
    }
  }

  /// Check if cached weather is still valid
  /// Returns true if cache exists and is within validity period
  /// Returns false if no cache or expired
  Future<bool> isCurrentWeatherValid() async {
    try {
      // Guard: Check initialization
      if (_weatherBox == null) {
        return false;
      }

      // Get timestamp
      final timestampStr = _weatherBox!.get(_weatherTimestampKey);

      if (timestampStr == null) {
        return false;
      }

      // Parse timestamp
      final timestamp = DateTime.parse(timestampStr as String);

      // Check if within validity period
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      final isValid = difference < _weatherCacheValidity;

      if (isValid) {
        print('Weather cache is valid (${difference.inMinutes} min old)');
      } else {
        print('Weather cache expired (${difference.inMinutes} min old)');
      }

      return isValid;
    } catch (e) {
      print('Error checking weather cache validity: $e');
      return false;
    }
  }

  /// Get age of cached weather in minutes
  /// Returns null if no cache exists
  Future<int?> getCurrentWeatherAgeMinutes() async {
    try {
      if (_weatherBox == null) {
        return null;
      }

      final timestampStr = _weatherBox!.get(_weatherTimestampKey);
      if (timestampStr == null) {
        return null;
      }

      final timestamp = DateTime.parse(timestampStr as String);
      final difference = DateTime.now().difference(timestamp);

      return difference.inMinutes;
    } catch (e) {
      print('Error getting weather cache age: $e');
      return null;
    }
  }

  /// Clear current weather cache
  /// Removes both data and timestamp
  Future<void> clearCurrentWeather() async {
    try {
      if (_weatherBox == null) {
        return;
      }

      await _weatherBox!.delete(_currentWeatherKey);
      await _weatherBox!.delete(_weatherTimestampKey);

      print('Current weather cache cleared');
    } catch (e) {
      print('Error clearing weather cache: $e');
    }
  }

  /// Save forecast list to cache
  /// Stores forecast as list of JSON maps
  Future<void> saveForecast(List<ForecastDailyModel> forecast) async {
    try {
      // Guard: Check initialization
      if (_forecastBox == null) {
        throw Exception('Cache service not initialized');
      }

      // Convert list to JSON
      final forecastJsonList = forecast.map((f) => f.toJson()).toList();

      // Save forecast data
      await _forecastBox!.put(_forecastKey, forecastJsonList);

      // Save timestamp
      await _forecastBox!.put(
        _forecastTimestampKey,
        DateTime.now().toIso8601String(),
      );

      print('Forecast cached: ${forecast.length} days');
    } catch (e) {
      print('Error saving forecast to cache: $e');
      rethrow;
    }
  }

  /// Retrieve forecast from cache
  /// Returns empty list if no cached data exists
  Future<List<ForecastDailyModel>> getForecast() async {
    try {
      // Guard: Check initialization
      if (_forecastBox == null) {
        throw Exception('Cache service not initialized');
      }

      // Get cached JSON list
      final forecastJsonList = _forecastBox!.get(_forecastKey);

      if (forecastJsonList == null) {
        print('No cached forecast found');
        return [];
      }

      // Parse JSON list to models
      final List<dynamic> jsonList = forecastJsonList as List<dynamic>;
      final forecast = jsonList
          .map(
            (json) => ForecastDailyModel.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .toList();

      print('Retrieved cached forecast: ${forecast.length} days');
      return forecast;
    } catch (e) {
      print('Error retrieving cached forecast: $e');
      return [];
    }
  }

  /// Check if cached forecast is still valid
  /// Returns true if cache exists and is within validity period
  Future<bool> isForecastValid() async {
    try {
      // Guard: Check initialization
      if (_forecastBox == null) {
        return false;
      }

      // Get timestamp
      final timestampStr = _forecastBox!.get(_forecastTimestampKey);

      if (timestampStr == null) {
        return false;
      }

      // Parse timestamp
      final timestamp = DateTime.parse(timestampStr as String);

      // Check if within validity period
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      final isValid = difference < _forecastCacheValidity;

      if (isValid) {
        print('Forecast cache is valid (${difference.inMinutes} min old)');
      } else {
        print('Forecast cache expired (${difference.inMinutes} min old)');
      }

      return isValid;
    } catch (e) {
      print('Error checking forecast cache validity: $e');
      return false;
    }
  }

  /// Clear forecast cache
  /// Removes both data and timestamp
  Future<void> clearForecast() async {
    try {
      if (_forecastBox == null) {
        return;
      }

      await _forecastBox!.delete(_forecastKey);
      await _forecastBox!.delete(_forecastTimestampKey);

      print('Forecast cache cleared');
    } catch (e) {
      print('Error clearing forecast cache: $e');
    }
  }

  /// Clear all cached data
  /// Removes both current weather and forecast
  /// Useful for logout or manual cache reset
  Future<void> clearAll() async {
    try {
      await clearCurrentWeather();
      await clearForecast();
      print('All cache cleared');
    } catch (e) {
      print('Error clearing all cache: $e');
    }
  }

  /// Get total cache size in bytes
  /// Useful for debugging or settings screen
  Future<int> getCacheSize() async {
    try {
      int size = 0;

      if (_weatherBox != null) {
        // Approximate size calculation
        size += _weatherBox!.length * 500; // ~500 bytes per weather entry
      }

      if (_forecastBox != null) {
        size += _forecastBox!.length * 200; // ~200 bytes per forecast entry
      }

      return size;
    } catch (e) {
      print('Error calculating cache size: $e');
      return 0;
    }
  }

  /// Check if any cache exists
  /// Returns true if either weather or forecast is cached
  Future<bool> hasAnyCache() async {
    try {
      final hasWeather = _weatherBox?.containsKey(_currentWeatherKey) ?? false;
      final hasForecast = _forecastBox?.containsKey(_forecastKey) ?? false;

      return hasWeather || hasForecast;
    } catch (e) {
      print('Error checking cache existence: $e');
      return false;
    }
  }

  /// Get last cache update time
  /// Returns null if no cache exists
  Future<DateTime?> getLastCacheUpdate() async {
    try {
      if (_weatherBox == null) {
        return null;
      }

      final timestampStr = _weatherBox!.get(_weatherTimestampKey);
      if (timestampStr == null) {
        return null;
      }

      return DateTime.parse(timestampStr as String);
    } catch (e) {
      print('Error getting last cache update: $e');
      return null;
    }
  }

  /// Close all Hive boxes
  /// Should be called when app is closing
  /// Optional - Hive closes boxes automatically
  Future<void> dispose() async {
    try {
      await _weatherBox?.close();
      await _forecastBox?.close();
      print('Cache service disposed');
    } catch (e) {
      print('Error disposing cache service: $e');
    }
  }
}
