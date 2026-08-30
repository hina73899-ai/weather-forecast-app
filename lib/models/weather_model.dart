import 'package:flutter/material.dart';

class WeatherModel {
  final double currentTemp;
  final double apparentTemp; // RealFeel
  final double uvIndex;      // UV Index
  final int rainChance;      // Rain %
  final HourlyWeather hourly;
  final DailyWeather daily;

  WeatherModel({
    required this.currentTemp,
    required this.apparentTemp,
    required this.uvIndex,
    required this.rainChance,
    required this.hourly,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final hourlyData = json['hourly'] ?? {};

    // Hourly array me se pehle index (current hour) ka data pick kiya gaya hai
    final rainList = (hourlyData['precipitation_probability'] as List<dynamic>?) ?? [];
    final uvList = (hourlyData['uv_index'] as List<dynamic>?) ?? [];
    final apparentList = (hourlyData['apparent_temperature'] as List<dynamic>?) ?? [];

    return WeatherModel(
      currentTemp: (json['current_weather']?['temperature'] as num?)?.toDouble() ?? 0.0,
      apparentTemp: apparentList.isNotEmpty
          ? (apparentList[0] as num).toDouble()
          : ((json['current_weather']?['temperature'] as num?)?.toDouble() ?? 0.0),
      uvIndex: uvList.isNotEmpty ? (uvList[0] as num).toDouble() : 0.0,
      rainChance: rainList.isNotEmpty ? (rainList[0] as num).toInt() : 0,
      hourly: HourlyWeather.fromJson(hourlyData),
      daily: DailyWeather.fromJson(json['daily'] ?? {}),
    );
  }
}

// -----------------------------------------------------------------------------
// HOURLY WEATHER MODEL (24 Hours Forecast)
// -----------------------------------------------------------------------------
class HourlyWeather {
  final List<String> time;
  final List<double> temperature;
  final List<int> precipitation; // Chance of Rain %

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.precipitation,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: List<String>.from(json['time'] ?? []),
      temperature: (json['temperature_2m'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
          [],
      precipitation: (json['precipitation_probability'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
          [],
    );
  }
}

// -----------------------------------------------------------------------------
// DAILY WEATHER MODEL (7-Day Forecast)
// -----------------------------------------------------------------------------
class DailyWeather {
  final List<String> time;
  final List<double> maxTemp;
  final List<double> minTemp;
  final List<int> weatherCode;
  final List<int> precipitationMax; // Daily Max Rain Chance %

  DailyWeather({
    required this.time,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.precipitationMax,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      time: List<String>.from(json['time'] ?? []),
      maxTemp: (json['temperature_2m_max'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
          [],
      minTemp: (json['temperature_2m_min'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
          [],
      weatherCode: (json['weathercode'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
          [],
      precipitationMax: (json['precipitation_probability_max'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
          [],
    );
  }
}