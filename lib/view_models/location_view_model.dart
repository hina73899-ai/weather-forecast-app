import 'package:flutter/material.dart';
import '../data/response/api_response.dart';
import '../models/weather_model.dart';
import '../repository/weather_repository.dart';

class LocationViewModel extends ChangeNotifier {
  final _myRepo = WeatherRepository();

  ApiResponse<WeatherModel> weatherList = ApiResponse.Loading();

  String _currentCity = "Lahore";
  double _currentLat = 31.5497;
  double _currentLong = 74.3436;

  String get currentCity => _currentCity;

  void setWeatherList(ApiResponse<WeatherModel> response) {
    weatherList = response;
    notifyListeners();
  }

  // Dynamic Weather Fetch by City Coordinates
  Future<void> fetchWeatherApi(String cityName, double lat, double long) async {
    _currentCity = cityName;
    _currentLat = lat;
    _currentLong = long;
    setWeatherList(ApiResponse.Loading());

    _myRepo.fetchWeatherApi(lat, long).then((value) {
      setWeatherList(ApiResponse.Completed(value));
    }).onError((error, stackTrace) {
      setWeatherList(ApiResponse.Error(error.toString()));
    });
  }
}