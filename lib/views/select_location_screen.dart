import 'package:flutter/material.dart';

class SelectLocationScreen extends ChangeNotifier {
  String _selectedCity = "SelectedCity";
  String get selectedCity => _selectedCity;

  void updatedLocation(String newCity) {
    _selectedCity = newCity;
    notifyListeners();
  }


}