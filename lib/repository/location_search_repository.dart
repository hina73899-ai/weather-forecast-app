import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/location_model.dart';

class LocationSearchService {
  static Future<List<LocationModel>> searchCities(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=10&language=en&format=json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          return (data['results'] as List)
              .map((item) => LocationModel.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      debugPrint("Geocoding API Error: $e");
    }
    return [];
  }
}