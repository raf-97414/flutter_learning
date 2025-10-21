import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/cache_services.dart';
import 'package:weather_app/services/location_services.dart';
import 'package:weather_app/services/weather_services.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherModel? _current;
  bool _loading = false;
  String? _error;
  bool _offline = false;

  final WeatherService _service;
  final CacheServices _cache;
  final LocationServices _location;
  final Connectivity _connectivity;
  final Dio _dio;

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  WeatherProvider({
    WeatherService? service,
    CacheServices? cache,
    LocationServices? location,
    Connectivity? connectivity,
    Dio? dio,
  }) : _dio = dio ?? Dio(),
       _service = service ?? WeatherService(dio ?? Dio()),
       _cache = cache ?? CacheServices(),
       _location = location ?? LocationServices(),
       _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  WeatherModel? get current => _current;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isOffline => _offline;

  Future<void> _init() async {
    try {
      await _cache.init();
    } catch (e) {
      debugPrint('Cache initialization failed: $e');
    }

    try {
      final initial = await _connectivity.checkConnectivity();
      _offline = initial == ConnectivityResult.none;
    } catch (e) {
      debugPrint('Connectivity initial check failed: $e');
      _offline = false;
    }

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((status) {
              final wasOffline = _offline;
              _offline = status == ConnectivityResult.none;
              if (_offline != wasOffline) notifyListeners();
            })
            as StreamSubscription<ConnectivityResult>?;

    try {
      final cached = await _cache.getCurrentWeather();
      if (cached != null) {
        _current = cached;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load cached weather: $e');
    }
  }

  Future<void> loadWeather({bool forceRefresh = false}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (!forceRefresh) {
        try {
          final cached = await _cache.getCurrentWeather();
          if (cached != null) {
            _current = cached;
            _loading = false;
            notifyListeners();
            if (!_offline) _refreshInBackground();
            return;
          }
        } catch (e) {
          debugPrint('Cache read failed: $e');
        }
      }

      if (_offline) {
        _error = 'No internet connection';
        _loading = false;
        notifyListeners();
        return;
      }

      final loc = await _location.getCurrentLocation();

      final fresh = await _service.fetchCurrentWeather(
        loc.latitude,
        loc.longitude,
      );

      _current = fresh;
      try {
        await _cache.saveCurrentWeather(fresh);
      } catch (e) {
        debugPrint('Failed to save weather to cache: $e');
      }
    } catch (e, st) {
      debugPrint('WeatherProvider.loadWeather error: $e\n$st');
      _error = 'Unexpected error: ${e.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshInBackground() async {
    try {
      final loc = await _location.getCurrentLocation();

      final fresh = await _service.fetchCurrentWeather(
        loc.latitude,
        loc.longitude,
      );

      if (fresh != null) {
        _current = fresh;
        try {
          await _cache.saveCurrentWeather(fresh);
        } catch (e) {
          debugPrint('Background cache save failed: $e');
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Background refresh failed: $e');
    }
  }

  Future<void> clearCache({bool clearForecast = true}) async {
    try {
      if (clearForecast) {
        await _cache.clearForecast();
      }
    } catch (e) {
      debugPrint('Failed to clear cache: $e');
    }
    _current = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
