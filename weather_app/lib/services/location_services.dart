import 'package:geolocator/geolocator.dart';

/// Simple, safe LocationServices wrapper around `geolocator`.
/// - exposes `getCurrentLocation()` which returns a record with latitude & longitude
/// - provides permission helpers and settings helpers
class LocationServices {
  LocationServices();

  /// Ensures permission is granted before accessing location.
  /// Returns true if granted, false otherwise.
  Future<bool> _handlePermission() async {
    final status = await Geolocator.checkPermission();

    if (status == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      return result == LocationPermission.whileInUse ||
          result == LocationPermission.always;
    }

    if (status == LocationPermission.deniedForever) {
      // Permission permanently denied.
      return false;
    }

    // Permission already granted (whileInUse or always)
    return true;
  }

  /// Retrieves the current GPS position.
  /// Throws [LocationPermissionException] if permission denied,
  /// or [LocationException] for other failures.
  Future<({double latitude, double longitude})> getCurrentLocation() async {
    try {
      final hasPermission = await _handlePermission();
      if (!hasPermission) {
        throw LocationPermissionException('Location permission denied.');
      }

      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) {
        throw LocationException(
          'Location services are disabled. Please enable GPS.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return (latitude: position.latitude, longitude: position.longitude);
    } on LocationPermissionException {
      rethrow;
    } catch (e) {
      throw LocationException('Failed to get location: $e');
    }
  }

  /// Returns true if location permission is granted.
  Future<bool> hasLocationPermission() async {
    final status = await Geolocator.checkPermission();
    return status == LocationPermission.whileInUse ||
        status == LocationPermission.always;
  }

  /// Opens location settings so the user can enable GPS.
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Opens app settings (useful when permission is denied forever).
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}

/// Custom exception for location permission errors.
class LocationPermissionException implements Exception {
  final String message;
  LocationPermissionException(this.message);
  @override
  String toString() => 'LocationPermissionException: $message';
}

/// Custom exception for general location errors.
class LocationException implements Exception {
  final String message;
  LocationException(this.message);
  @override
  String toString() => 'LocationException: $message';
}
