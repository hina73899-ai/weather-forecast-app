import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/App-colors.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  static const String _locationsKey = 'saved_locations';
  static const String _autoDetectionKey = 'automatic_detection';

  List<Map<String, dynamic>> _locations = [];

  bool _automaticDetection = true;
  bool _isLoading = true;
  bool _isDetectingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // ============================================================
  // LOAD SAVED DATA
  // ============================================================

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLocations = prefs.getStringList(_locationsKey) ?? [];

    final loadedLocations = savedLocations.map((item) {
      return Map<String, dynamic>.from(
        jsonDecode(item) as Map,
      );
    }).toList();

    final autoDetection = prefs.getBool(_autoDetectionKey) ?? true;

    if (!mounted) return;

    setState(() {
      _locations = loadedLocations;
      _automaticDetection = autoDetection;
      _isLoading = false;
    });

    // If there are no saved locations and automatic detection
    // is enabled, detect the current location.
    if (_locations.isEmpty && _automaticDetection) {
      await _detectCurrentLocation();
    }
  }

  // ============================================================
  // SAVE DATA LOCALLY
  // ============================================================

  Future<void> _saveLocations() async {
    final prefs = await SharedPreferences.getInstance();

    final encodedLocations = _locations
        .map((location) => jsonEncode(location))
        .toList();

    await prefs.setStringList(_locationsKey, encodedLocations);
  }

  Future<void> _saveAutomaticDetection(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_autoDetectionKey, value);
  }

  // ============================================================
  // AUTOMATIC LOCATION
  // ============================================================

  Future<void> _detectCurrentLocation() async {
    if (_isDetectingLocation) return;

    setState(() {
      _isDetectingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showMessage(
          'Please turn on Location/GPS from your phone settings.',
        );
        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _showMessage('Location permission was denied.');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage(
          'Location permission is permanently denied. '
              'Please enable it from app settings.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      String locationName = 'Current Location';
      String address = '';

      try {
        final geocoding = Geocoding();

        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );;

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          final city = place.locality?.trim() ?? '';
          final area = place.subLocality?.trim() ?? '';
          final country = place.country?.trim() ?? '';

          if (city.isNotEmpty) {
            locationName = city;
          } else if (area.isNotEmpty) {
            locationName = area;
          }

          final addressParts = <String>[];

          if (place.street != null &&
              place.street!.trim().isNotEmpty) {
            addressParts.add(place.street!.trim());
          }

          if (area.isNotEmpty) {
            addressParts.add(area);
          }

          if (city.isNotEmpty) {
            addressParts.add(city);
          }

          if (country.isNotEmpty) {
            addressParts.add(country);
          }

          address = addressParts.join(', ');
        }
      } catch (_) {
        // If reverse geocoding fails, coordinates will still be saved.
      }

      final newLocation = {
        'name': locationName,
        'address': address.isNotEmpty
            ? address
            : 'Current location',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'isCurrent': true,
      };

      // Remove previous current-location entry.
      _locations.removeWhere(
            (location) => location['isCurrent'] == true,
      );

      _locations.insert(0, newLocation);

      await _saveLocations();

      if (!mounted) return;

      setState(() {});

      _showMessage('Current location updated.');
    } catch (e) {
      _showMessage(
        'Could not detect your location. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDetectingLocation = false;
        });
      }
    }
  }

  // ============================================================
  // SEARCH LOCATION
  // ============================================================

  Future<List<Map<String, dynamic>>> _searchLocations(
      String query,
      ) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search'
          '?name=${Uri.encodeComponent(query.trim())}'
          '&count=10'
          '&language=en'
          '&format=json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(response.body);

      final results = data['results'];

      if (results == null) {
        return [];
      }

      return List<Map<String, dynamic>>.from(
        results.map(
              (item) => {
            'name': item['name'] ?? 'Unknown',
            'country': item['country'] ?? '',
            'admin1': item['admin1'] ?? '',
            'latitude': item['latitude'],
            'longitude': item['longitude'],
          },
        ),
      );
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // ADD LOCATION
  // ============================================================

  Future<void> _addLocation(
      Map<String, dynamic> result,
      ) async {
    final newLocation = {
      'name': result['name'],
      'address': _buildAddress(result),
      'latitude': result['latitude'],
      'longitude': result['longitude'],
      'isCurrent': false,
    };

    // Don't add duplicate locations.
    final alreadyExists = _locations.any(
          (location) =>
      location['latitude'] == newLocation['latitude'] &&
          location['longitude'] == newLocation['longitude'],
    );

    if (alreadyExists) {
      _showMessage('This location is already added.');
      return;
    }

    _locations.add(newLocation);

    await _saveLocations();

    if (!mounted) return;

    setState(() {});

    Navigator.pop(context);

    _showMessage('${result['name']} added successfully.');
  }

  String _buildAddress(Map<String, dynamic> result) {
    final parts = <String>[];

    final admin = result['admin1']?.toString() ?? '';
    final country = result['country']?.toString() ?? '';

    if (admin.isNotEmpty) {
      parts.add(admin);
    }

    if (country.isNotEmpty) {
      parts.add(country);
    }

    return parts.join(', ');
  }

  // ============================================================
  // DELETE LOCATION
  // ============================================================

  Future<void> _deleteLocation(int index) async {
    final location = _locations[index];

    // Current location can also be deleted if user wants.
    _locations.removeAt(index);

    await _saveLocations();

    if (!mounted) return;

    setState(() {});

    _showMessage(
      '${location['name']} removed.',
    );
  }

  // ============================================================
  // SELECT LOCATION
  // ============================================================

  Future<void> _selectLocation(int index) async {
    final selected = _locations[index];

    // Make every location non-current.
    for (final location in _locations) {
      location['isCurrent'] = false;
    }

    selected['isCurrent'] = true;

    // Move selected location to top.
    _locations.removeAt(index);
    _locations.insert(0, selected);

    await _saveLocations();

    if (!mounted) return;

    setState(() {});

    _showMessage(
      '${selected['name']} selected.',
    );
  }

  // ============================================================
  // ADD LOCATION DIALOG
  // ============================================================

  void _showAddLocationDialog() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _LocationSearchSheet(
          controller: controller,
          searchFunction: _searchLocations,
          onLocationSelected: _addLocation,
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101F58),

      appBar: AppBar(
        backgroundColor: const Color(0xFF080F68),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Locations',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            onPressed: _showAddLocationDialog,
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 27,
            ),
          ),
        ],
      ),

      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      )
          : RefreshIndicator(
        onRefresh: _detectCurrentLocation,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 30,
          ),
          children: [

            // ==================================================
            // AUTOMATIC DETECTION
            // ==================================================

            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF132B72),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [

                  const Icon(
                    Icons.near_me_outlined,
                    color: Colors.white,
                    size: 23,
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Text(
                      'Automatic detection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  Switch(
                    value: _automaticDetection,
                    activeThumbColor: Colors.white,
                    activeTrackColor:
                    Colors.teal,

                    onChanged: (value) async {
                      setState(() {
                        _automaticDetection = value;
                      });

                      await _saveAutomaticDetection(value);

                      if (value) {
                        await _detectCurrentLocation();
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // LOCATION LIST
            // ==================================================

            if (_locations.isEmpty)
              _buildEmptyState(),

            ...List.generate(
              _locations.length,
                  (index) {
                return _buildLocationItem(
                  _locations[index],
                  index,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 100,
        left: 30,
        right: 30,
      ),
      child: Column(
        children: [

          const Icon(
            Icons.location_off_outlined,
            color: Colors.white54,
            size: 60,
          ),

          const SizedBox(height: 15),

          const Text(
            'No locations added',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Tap + to add a location',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOCATION ITEM
  // ============================================================

  Widget _buildLocationItem(
      Map<String, dynamic> location,
      int index,
      ) {
    final bool isCurrent =
        location['isCurrent'] == true;

    final String name =
        location['name']?.toString() ??
            'Unknown location';

    final String address =
        location['address']?.toString() ??
            '';

    return Dismissible(
      key: ValueKey(
        '${location['latitude']}_${location['longitude']}_$index',
      ),

      direction: DismissDirection.endToStart,

      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Remove location?',
              ),
              content: Text(
                'Remove $name from your saved locations?',
              ),
              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      false,
                    );
                  },
                  child: const Text('Cancel'),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      true,
                    );
                  },
                  child: const Text(
                    'Remove',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
            false;
      },

      onDismissed: (_) {
        _deleteLocation(index);
      },

      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(
          right: 25,
        ),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),

      child: InkWell(
        onTap: () {
          _selectLocation(index);
        },

        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF142B70),
            borderRadius: BorderRadius.circular(8),
          ),

          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.center,

            children: [

              // Location icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(
                    0.05,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white70,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              // Name + address
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [

                        Flexible(
                          child: Text(
                            name,
                            maxLines: 2,
                            overflow:
                            TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),
                        ),

                        if (isCurrent)
                          Container(
                            margin:
                            const EdgeInsets.only(
                              left: 7,
                            ),
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius:
                              BorderRadius.circular(
                                5,
                              ),
                            ),
                            child: const Text(
                              'CURRENT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    if (address.isNotEmpty)
                      Padding(
                        padding:
                        const EdgeInsets.only(
                          top: 4,
                        ),
                        child: Text(
                          address,
                          maxLines: 2,
                          overflow:
                          TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              // Delete
              IconButton(
                onPressed: () {
                  _deleteLocation(index);
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.white38,
                  size: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// SEARCH BOTTOM SHEET
// ==================================================================

class _LocationSearchSheet extends StatefulWidget {
  final TextEditingController controller;

  final Future<List<Map<String, dynamic>>> Function(
      String query,
      ) searchFunction;

  final Future<void> Function(
      Map<String, dynamic> location,
      ) onLocationSelected;

  const _LocationSearchSheet({
    required this.controller,
    required this.searchFunction,
    required this.onLocationSelected,
  });

  @override
  State<_LocationSearchSheet> createState() =>
      _LocationSearchSheetState();
}

class _LocationSearchSheetState
    extends State<_LocationSearchSheet> {

  List<Map<String, dynamic>> _results = [];

  bool _isSearching = false;

  Future<void> _search() async {
    final query =
    widget.controller.text.trim();

    if (query.isEmpty) {
      setState(() {
        _results = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results =
    await widget.searchFunction(query);

    if (!mounted) return;

    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom =
        MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height *
            0.75,

        decoration: const BoxDecoration(
          color: Color(0xFF101F58),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(22),
          ),
        ),

        child: Column(
          children: [

            const SizedBox(height: 12),

            // Handle
            Container(
              width: 45,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius:
                BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Add Location',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: TextField(
                controller: widget.controller,

                autofocus: true,

                style: const TextStyle(
                  color: Colors.white,
                ),

                textInputAction:
                TextInputAction.search,

                onSubmitted: (_) {
                  _search();
                },

                decoration: InputDecoration(
                  hintText:
                  'Search city or location',

                  hintStyle: const TextStyle(
                    color: Colors.white54,
                  ),

                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white70,
                  ),

                  suffixIcon: IconButton(
                    onPressed: _search,
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),

                  filled: true,

                  fillColor:
                  const Color(0xFF182F6F),

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                    borderSide:
                    BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            if (_isSearching)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),

            Expanded(
              child: ListView.builder(
                physics:
                const BouncingScrollPhysics(),

                itemCount: _results.length,

                itemBuilder: (
                    context,
                    index,
                    ) {
                  final location =
                  _results[index];

                  final name =
                      location['name']
                          ?.toString() ??
                          'Unknown';

                  final country =
                      location['country']
                          ?.toString() ??
                          '';

                  final admin =
                      location['admin1']
                          ?.toString() ??
                          '';

                  final subtitle =
                  [
                    if (admin.isNotEmpty) admin,
                    if (country.isNotEmpty)
                      country,
                  ].join(', ');

                  return ListTile(
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white70,
                    ),

                    title: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),

                    subtitle: Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white60,
                      ),
                    ),

                    trailing: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                    ),

                    onTap: () async {
                      await widget
                          .onLocationSelected(
                        location,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}