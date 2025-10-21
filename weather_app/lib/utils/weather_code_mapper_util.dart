import 'package:flutter/material.dart';

class WeatherCodeMapperUtil {
  // code groups (kept for readability)
  static const List<int> clearCodes = [0, 1];
  static const List<int> cloudyCodes = [2, 3];
  static const List<int> fogCodes = [45, 48];
  static const List<int> rainCodes = [
    51,
    53,
    55,
    56,
    57,
    61,
    63,
    65,
    66,
    67,
    80,
    81,
    82,
  ];
  static const List<int> snowCodes = [71, 73, 75, 77, 85, 86];
  static const List<int> thunderStormCodes = [95, 96, 99];

  // Per-code lookup map built once (runtime). Each entry has title, description, iconKeyword.
  static final Map<int, Map<String, String>> _weatherMap = _buildWeatherMap();

  static Map<int, Map<String, String>> _buildWeatherMap() {
    final map = <int, Map<String, String>>{};

    // clear
    final clearTitles = ["Clear Sky", "Mainly Clear"];
    for (var i = 0; i < clearCodes.length; i++) {
      map[clearCodes[i]] = {
        'title': clearTitles[i],
        'desc': clearTitles[i],
        'icon': 'sun',
      };
    }

    // cloudy
    final cloudyTitles = ["Partly Cloudy", "Overcast"];
    for (var i = 0; i < cloudyCodes.length; i++) {
      map[cloudyCodes[i]] = {
        'title': cloudyTitles[i],
        'desc': cloudyTitles[i],
        'icon': 'cloud',
      };
    }

    // fog
    final fogTitles = ["Fog", "Freezing Fog"];
    for (var i = 0; i < fogCodes.length; i++) {
      map[fogCodes[i]] = {
        'title': fogTitles[i],
        'desc': fogTitles[i],
        'icon': 'fog',
      };
    }

    // rain — one description per code (keeps indexes aligned)
    final rainTitles = [
      "Light Drizzle",
      "Moderate Drizzle",
      "Dense Drizzle",
      "Light Freezing Drizzle",
      "Dense Freezing Drizzle",
      "Light Rain",
      "Moderate Rain",
      "Heavy Rain",
      "Light Freezing Rain",
      "Heavy Freezing Rain",
      "Light Rain Showers",
      "Moderate Rain Showers",
      "Violent Rain Showers",
    ];
    for (var i = 0; i < rainCodes.length; i++) {
      map[rainCodes[i]] = {
        'title': rainTitles[i],
        'desc': rainTitles[i],
        'icon': 'rain',
      };
    }

    // snow
    final snowTitles = [
      "Light Snow",
      "Moderate Snow",
      "Heavy Snow",
      "Snow Grains",
      "Light Snow Showers",
      "Heavy Snow Showers",
    ];
    for (var i = 0; i < snowCodes.length; i++) {
      map[snowCodes[i]] = {
        'title': snowTitles[i],
        'desc': snowTitles[i],
        'icon': 'snow',
      };
    }

    // thunder
    final thunderTitles = [
      "Thunderstorm",
      "Thunderstorm with Light Hail",
      "Thunderstorm with Heavy Hail",
    ];
    for (var i = 0; i < thunderStormCodes.length; i++) {
      map[thunderStormCodes[i]] = {
        'title': thunderTitles[i],
        'desc': thunderTitles[i],
        'icon': 'thunder',
      };
    }

    return map;
  }

  // Returns condition name (short)
  static String getConditionName(int code) {
    return _weatherMap[code]?['title'] ?? 'Unknown Condition';
  }

  // Returns longer description
  static String getDescriptionName(int code) {
    return _weatherMap[code]?['desc'] ?? 'No description available';
  }

  // Returns an Icon widget for a given weather code
  static Icon getIconForCode(
    int code,
    Map<dynamic, int> map, {
    double size = 24,
  }) {
    final iconKeyword = _weatherMap[code]?['icon'];
    return Icon(_iconDataForKeyword(iconKeyword), size: size);
  }

  // Helper: map keyword -> IconData (use only existing Material icons)
  static IconData _iconDataForKeyword(String? keyword) {
    switch (keyword) {
      case 'sun':
        return Icons.wb_sunny;
      case 'cloud':
        return Icons.cloud;
      case 'rain':
        return Icons.water_drop; // close visual for rain
      case 'snow':
        return Icons.ac_unit;
      case 'fog':
        return Icons.deblur; // best approximate for fog
      case 'thunder':
        return Icons.flash_on;
      default:
        return Icons.help_outline;
    }
  }
}
