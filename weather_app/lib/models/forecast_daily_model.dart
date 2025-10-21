import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/utils/weather_code_mapper_util.dart';

/// Represents a single day's weather forecast
/// Immutable model for daily forecast summary data from Open-Meteo API
@HiveType(typeId: 1)
class ForecastDailyModel {
  /// The date this forecast is for
  @HiveField(0)
  final DateTime date;

  /// Maximum temperature for the day (Celsius)
  @HiveField(1)
  final double maxTemperature;

  /// Minimum temperature for the day (Celsius)
  @HiveField(2)
  final double minTemperature;

  /// WMO weather code (0-99)
  @HiveField(3)
  final int weatherCode;

  /// Total precipitation for the day (mm)
  /// Nullable - may not be provided by API
  @HiveField(4)
  final double? precipitationSum;

  /// Maximum probability of precipitation (0-100%)
  /// Nullable - may not be provided by API
  @HiveField(5)
  final int? precipitationProbability;

  /// Maximum wind speed for the day (km/h)
  /// Nullable - optional enhancement
  @HiveField(6)
  final double? windSpeedMax;

  /// Sunrise time for the day
  /// Nullable - depends on API data availability
  @HiveField(7)
  final DateTime? sunrise;

  /// Sunset time for the day
  /// Nullable - depends on API data availability
  @HiveField(8)
  final DateTime? sunset;

  /// UV index maximum for the day
  /// Nullable - optional health data
  @HiveField(9)
  final int? uvIndexMax;

  /// Primary constructor with required and optional parameters
  /// All critical fields (date, temps, code) are required
  /// Enhancement fields are optional for flexibility
  ForecastDailyModel({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.weatherCode,
    this.precipitationSum,
    this.precipitationProbability,
    this.windSpeedMax,
    this.sunrise,
    this.sunset,
    this.uvIndexMax,
  });

  // ============================================================================
  // COMPUTED PROPERTIES (Getters)
  // ============================================================================

  /// Get human-readable weather condition name
  /// Maps weatherCode to readable string using WeatherCodeMapperUtil
  /// Examples: "Partly Cloudy", "Light Rain", "Clear"
  /// Computed on-demand, never stored
  String get condition => WeatherCodeMapperUtil.getConditionName(weatherCode);

  /// Get detailed weather description
  /// More verbose than condition, includes context
  /// Example: "Overcast with intermittent light rain expected"
  /// Useful for detail screens and tooltips
  String get description =>
      WeatherCodeMapperUtil.getDescriptionName(weatherCode);

  /// Get icon widget for this weather condition
  /// Returns Material Design Icon based on weather code
  /// Size: 24 by default, can be customized
  /// Example: Icon(Icons.cloud)
  dynamic get iconData =>
      WeatherCodeMapperUtil.getIconForCode(weatherCode, {}, size: 24);

  /// Get human-readable day label
  /// Returns "Today", "Tomorrow", or day of week name
  /// Critical for UX - users think in relative terms
  /// Examples: "Today", "Tomorrow", "Monday", "Friday"
  String get dayName {
    // Get current date and time
    final dateTimeNow = DateTime.now();

    // Normalize today to midnight (remove time component)
    // Why? Because we only care about the date, not the time
    final dateNow = DateTime(
      dateTimeNow.year,
      dateTimeNow.month,
      dateTimeNow.day,
    );

    // Normalize forecast date to midnight (remove time component)
    final dateNormal = DateTime(date.year, date.month, date.day);

    // Calculate difference in days
    // 0 = same day, 1 = next day, 2 = day after, etc.
    final days = dateNormal.difference(dateNow).inDays;

    // Return appropriate label based on difference
    if (days == 0) {
      return 'Today';
    } else if (days == 1) {
      return 'Tomorrow';
    } else {
      // For any other day, return the day of week name
      // 'EEEE' = full day name (Monday, Tuesday, Wednesday, etc.)
      return DateFormat('EEEE').format(date);
    }
  }

  // ============================================================================
  // HELPER GETTERS
  // ============================================================================

  /// Temperature range formatted as string
  /// Useful for compact UI display
  /// Example: "18° / 24°" (min / max)
  /// Returns integers by rounding, not decimals
  String get temperatureRange {
    return '${minTemperature.round()}° / ${maxTemperature.round()}°';
  }

  /// Check if rain is expected for this day
  /// Returns true if weather code indicates rain OR precipitation > 0
  /// Useful for conditional UI elements (show umbrella icon)
  /// Checks both weather code mapping and actual precipitation data
  bool get hasRain {
    return WeatherCodeMapperUtil.rainCodes.contains(weatherCode) ||
        (precipitationSum != null && precipitationSum! > 0);
  }

  /// Check if snow is expected
  /// Returns true if weather code indicates snow
  /// Useful for winter weather warnings or themed UI
  bool get hasSnow {
    return WeatherCodeMapperUtil.snowCodes.contains(weatherCode);
  }

  /// Check for severe weather conditions
  /// Returns true for thunderstorms or heavy precipitation
  /// Useful for displaying alert badges or warnings
  bool get isSevere {
    return WeatherCodeMapperUtil.thunderStormCodes.contains(weatherCode) ||
        weatherCode == 65 || // Heavy Rain
        weatherCode == 75 || // Heavy Snow
        weatherCode == 82; // Violent Rain Showers
  }

  /// Get formatted date string
  /// Example: "Oct 14" or "Oct 14, 2025"
  /// Useful for display in forecast cards
  String get formattedDate {
    return DateFormat('MMM dd').format(date);
  }

  /// Get full formatted date with year
  /// Example: "October 14, 2025"
  /// For detailed displays or sharing
  String get formattedDateFull {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  /// Check if this day is in the past
  /// Useful for disabling past days in UI
  /// Returns true if date is before today
  bool get isPast {
    final now = DateTime.now();
    final normalizedToday = DateTime(now.year, now.month, now.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return normalizedDate.isBefore(normalizedToday);
  }

  /// Get day of week as short form
  /// Example: "Mon", "Tue", "Wed"
  /// For compact displays
  String get dayOfWeekShort {
    return DateFormat('EEE').format(date);
  }

  /// Check if has significant precipitation
  /// Returns true if precipitation sum > 2mm
  /// Useful for flagging rainy days
  bool get hasPrecipitation {
    return precipitationSum != null && precipitationSum! > 2.0;
  }

  /// Get precipitation probability percentage
  /// Returns the probability or 0 if not available
  /// Useful for displaying rain chance
  int get rainProbability {
    return precipitationProbability ?? 0;
  }

  /// Get wind speed text representation
  /// Returns formatted wind speed or "No wind"
  String get windSpeedText {
    if (windSpeedMax == null || windSpeedMax == 0) {
      return 'No wind';
    }
    return '${windSpeedMax!.round()} km/h';
  }

  // ============================================================================
  // JSON SERIALIZATION & DESERIALIZATION
  // ============================================================================

  /// Serialize to Map for Hive caching
  /// Converts all fields including DateTime objects
  /// DateTime converted to ISO8601 string for storage
  /// All fields included for complete reconstruction
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'maxTemperature': maxTemperature,
      'minTemperature': minTemperature,
      'weatherCode': weatherCode,
      'precipitationSum': precipitationSum,
      'precipitationProbability': precipitationProbability,
      'windSpeedMax': windSpeedMax,
      'sunrise': sunrise?.toIso8601String(),
      'sunset': sunset?.toIso8601String(),
      'uvIndexMax': uvIndexMax,
    };
  }

  /// Deserialize from cached Map
  /// Reconstructs ForecastDailyModel from toJson output
  /// Parses DateTime strings back to DateTime objects
  /// Useful for loading from local cache/Hive
  factory ForecastDailyModel.fromJson(Map<String, dynamic> json) {
    return ForecastDailyModel(
      date: DateTime.parse(json['date'] as String),
      maxTemperature: (json['maxTemperature'] as num).toDouble(),
      minTemperature: (json['minTemperature'] as num).toDouble(),
      weatherCode: json['weatherCode'] as int,
      precipitationSum: json['precipitationSum'] != null
          ? (json['precipitationSum'] as num).toDouble()
          : null,
      precipitationProbability: json['precipitationProbability'] as int?,
      windSpeedMax: json['windSpeedMax'] != null
          ? (json['windSpeedMax'] as num).toDouble()
          : null,
      sunrise: json['sunrise'] != null
          ? DateTime.parse(json['sunrise'] as String)
          : null,
      sunset: json['sunset'] != null
          ? DateTime.parse(json['sunset'] as String)
          : null,
      uvIndexMax: json['uvIndexMax'] as int?,
    );
  }

  // ============================================================================
  // API PARSING (From Open-Meteo Response)
  // ============================================================================

  /// Construct single ForecastDailyModel from individual array elements
  /// Used when parsing arrays element by element
  /// Alternative to listFromJson if parsing logic is elsewhere
  factory ForecastDailyModel.fromArrayElements({
    required String dateString,
    required double maxTemp,
    required double minTemp,
    required int code,
    double? precipSum,
    int? precipProb,
    double? windSpeedMax,
    String? sunriseStr,
    String? sunsetStr,
    int? uvMax,
  }) {
    return ForecastDailyModel(
      date: DateTime.parse(dateString),
      maxTemperature: maxTemp,
      minTemperature: minTemp,
      weatherCode: code,
      precipitationSum: precipSum,
      precipitationProbability: precipProb,
      windSpeedMax: windSpeedMax,
      sunrise: sunriseStr != null ? DateTime.parse(sunriseStr) : null,
      sunset: sunsetStr != null ? DateTime.parse(sunsetStr) : null,
      uvIndexMax: uvMax,
    );
  }

  /// Parse Open-Meteo API response into List<ForecastDailyModel>
  /// STATIC METHOD - Call on class, not instance
  /// Handles parallel array structure from API
  /// Open-Meteo returns daily data as arrays, not objects:
  ///   time: [date1, date2, date3, ...]
  ///   temp_max: [24.5, 26.1, 23.8, ...]
  ///   weather_code: [2, 1, 61, ...]
  /// This method zips arrays into individual model instances
  /// Returns up to 7 days (you'll display 5)
  static List<ForecastDailyModel> listFromJson(Map<String, dynamic> dailyJson) {
    final List<ForecastDailyModel> forecasts = [];

    try {
      // Extract all arrays from daily object
      final List<dynamic> timeArray = dailyJson['time'] as List<dynamic>? ?? [];
      final List<dynamic> maxTempArray =
          dailyJson['temperature_2m_max'] as List<dynamic>? ?? [];
      final List<dynamic> minTempArray =
          dailyJson['temperature_2m_min'] as List<dynamic>? ?? [];
      final List<dynamic> codeArray =
          dailyJson['weather_code'] as List<dynamic>? ?? [];
      final List<dynamic>? precipSumArray =
          dailyJson['precipitation_sum'] as List<dynamic>?;
      final List<dynamic>? precipProbArray =
          dailyJson['precipitation_probability_max'] as List<dynamic>?;
      final List<dynamic>? windSpeedArray =
          dailyJson['wind_speed_10m_max'] as List<dynamic>?;
      final List<dynamic>? sunriseArray =
          dailyJson['sunrise'] as List<dynamic>?;
      final List<dynamic>? sunsetArray = dailyJson['sunset'] as List<dynamic>?;
      final List<dynamic>? uvArray =
          dailyJson['uv_index_max'] as List<dynamic>?;

      // Validate arrays have data
      if (timeArray.isEmpty || maxTempArray.isEmpty || minTempArray.isEmpty) {
        return forecasts; // Return empty list if no data
      }

      // Get length of forecast (limit to 7 days)
      final length = timeArray.length;
      final maxDays = length > 7 ? 7 : length;

      // Loop through each day and build model
      for (int i = 0; i < maxDays; i++) {
        try {
          // Safely extract values with bounds checking
          final dateStr = timeArray[i].toString();
          final maxTemp = (maxTempArray[i] as num?)?.toDouble() ?? 0.0;
          final minTemp = (minTempArray[i] as num?)?.toDouble() ?? 0.0;
          final code = (codeArray[i] as num?)?.toInt() ?? 0;
          final precipSum = precipSumArray != null
              ? (precipSumArray[i] as num?)?.toDouble()
              : null;
          final precipProb = precipProbArray != null
              ? (precipProbArray[i] as num?)?.toInt()
              : null;
          final windSpeed = windSpeedArray != null
              ? (windSpeedArray[i] as num?)?.toDouble()
              : null;
          final sunrise = sunriseArray != null
              ? sunriseArray[i]?.toString()
              : null;
          final sunset = sunsetArray != null
              ? sunsetArray[i]?.toString()
              : null;
          final uvMax = uvArray != null ? (uvArray[i] as num?)?.toInt() : null;

          // Create model instance
          final forecast = ForecastDailyModel.fromArrayElements(
            dateString: dateStr,
            maxTemp: maxTemp,
            minTemp: minTemp,
            code: code,
            precipSum: precipSum,
            precipProb: precipProb,
            windSpeedMax: windSpeed,
            sunriseStr: sunrise,
            sunsetStr: sunset,
            uvMax: uvMax,
          );

          forecasts.add(forecast);
        } catch (e) {
          // Log parsing error for this day, continue with next
          print('Error parsing forecast day $i: $e');
          continue;
        }
      }
    } catch (e) {
      // Log overall parsing error
      print('Error parsing daily forecast: $e');
      return []; // Return empty list on critical error
    }

    return forecasts;
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Override toString for better debugging
  /// Displays useful information when printing object
  @override
  String toString() {
    return 'ForecastDailyModel('
        'date: $date, '
        'dayName: $dayName, '
        'tempRange: $temperatureRange, '
        'condition: $condition, '
        'rain: $hasRain'
        ')';
  }

  /// Compare two ForecastDailyModel instances
  /// Useful for testing and state management
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ForecastDailyModel &&
        other.date == date &&
        other.maxTemperature == maxTemperature &&
        other.minTemperature == minTemperature &&
        other.weatherCode == weatherCode &&
        other.precipitationSum == precipitationSum &&
        other.precipitationProbability == precipitationProbability;
  }

  /// Generate hash code for use in Sets/Maps
  /// Must be consistent with operator==
  @override
  int get hashCode {
    return Object.hash(
      date,
      maxTemperature,
      minTemperature,
      weatherCode,
      precipitationSum,
      precipitationProbability,
    );
  }

  /// Create a copy of this model with some fields modified
  /// Useful for updates while maintaining immutability
  /// Example: forecastDay.copyWith(windSpeedMax: 25.0)
  ForecastDailyModel copyWith({
    DateTime? date,
    double? maxTemperature,
    double? minTemperature,
    int? weatherCode,
    double? precipitationSum,
    int? precipitationProbability,
    double? windSpeedMax,
    DateTime? sunrise,
    DateTime? sunset,
    int? uvIndexMax,
  }) {
    return ForecastDailyModel(
      date: date ?? this.date,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      minTemperature: minTemperature ?? this.minTemperature,
      weatherCode: weatherCode ?? this.weatherCode,
      precipitationSum: precipitationSum ?? this.precipitationSum,
      precipitationProbability:
          precipitationProbability ?? this.precipitationProbability,
      windSpeedMax: windSpeedMax ?? this.windSpeedMax,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      uvIndexMax: uvIndexMax ?? this.uvIndexMax,
    );
  }
}
