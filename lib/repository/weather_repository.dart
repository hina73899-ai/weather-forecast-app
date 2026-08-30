import 'package:flutter/material.dart';

import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../models/weather_model.dart';
import '../res/app_url.dart';

class WeatherRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<WeatherModel> fetchWeatherApi(double lat, double long) async {
    try {
      // Updated endpoint with apparent_temperature & uv_index for Favorite Index section
      String url =
          '${AppUrl.registeredApiEndpoints}?latitude=$lat&longitude='
          '$long&current_weather=true&hourly=temperature_2m,'
          'precipitation_probability,apparent_temperature,uv_index'
          '&daily=temperature_2m_max,temperature_2m_min,weathercode,'
          'precipitation_probability_max&timezone=auto';

      dynamic response = await _apiServices.getGetApiResponse(url);

      return WeatherModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}