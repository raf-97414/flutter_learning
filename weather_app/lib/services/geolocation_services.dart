import 'package:dio/dio.dart';

class GeolocationServices {
  final Dio _dio;
  GeolocationServices(this._dio);

  /// Search cities by name (returns up to 10 results)
  Future<List<CityResult>> searchCities(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': query, // City name to search
        'count': '10', // Return max 10 results
        'language': 'en',
        'format': 'json',
      });

      final response = await _dio.get(
        uri.toString(),
        options: Options(receiveTimeout: const Duration(seconds: 8)),
      );

      if (response.statusCode != 200) return [];

      final data = response.data;
      if (data is! Map<String, dynamic>) return [];

      final results = (data['results'] as List<dynamic>?) ?? [];
      return results
          .whereType<Map<String, dynamic>>()
          .map((json) => CityResult.fromJson(json))
          .toList();
    } catch (e) {
      // Consider logging the error more robustly in production
      print('Search error: $e');
      return [];
    }
  }

  /// Reverse geocode: get a city name from coordinates
  Future<String> getCityFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/reverse', {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'language': 'en',
      });

      final response = await _dio.get(
        uri.toString(),
        options: Options(receiveTimeout: const Duration(seconds: 8)),
      );

      if (response.statusCode != 200) return 'Unknown Location';

      final data = response.data;
      if (data is! Map<String, dynamic>) return 'Unknown Location';

      final results = (data['results'] as List<dynamic>?) ?? [];
      if (results.isNotEmpty) {
        final first = results.first;
        if (first is Map<String, dynamic>) {
          final cityName = first['name'] as String?;
          return cityName ?? 'Unknown Location';
        }
      }

      return 'Unknown Location';
    } catch (e) {
      print('Reverse geocoding error: $e');
      return 'Unknown Location';
    }
  }
}

class CityResult {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  String get displayName => '$name, $country';

  CityResult({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory CityResult.fromJson(Map<String, dynamic> json) {
    // Safely parse latitude/longitude which may be number or string
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    final name = (json['name'] as String?)?.trim() ?? 'Unknown';
    // API sometimes returns 'country' or 'country_code' or 'admin1'
    final country =
        (json['country'] as String?) ??
        (json['country_code'] as String?) ??
        (json['admin1'] as String?) ??
        'Unknown';

    final latitude = parseDouble(json['latitude'] ?? json['lat']);
    final longitude = parseDouble(
      json['longitude'] ?? json['lon'] ?? json['lng'],
    );

    return CityResult(
      name: name,
      country: country,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
