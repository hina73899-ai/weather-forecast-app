import 'package:flutter/material.dart';


import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  final MapController _mapController = MapController();

  // Default location.
  // It will be replaced by the user's actual GPS location.
  LatLng _currentLocation = const LatLng(
    31.5204,
    74.3587,
  );

  bool _loadingLocation = true;
  bool _loadingRadar = true;
  bool _isPlaying = false;

  String? _errorMessage;

  List<RadarFrame> _radarFrames = [];

  int _selectedFrame = 0;

  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();

    _initializeRadar();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> _initializeRadar() async {
    await _getCurrentLocation();
    await _loadRadarData();
  }

  // ============================================================
  // GET CURRENT LOCATION
  // ============================================================

  Future<void> _getCurrentLocation() async {
    try {
      final serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _loadingLocation = false;
        });

        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        setState(() {
          _loadingLocation = false;
        });

        return;
      }

      final position =
      await Geolocator.getCurrentPosition(
        locationSettings:
        const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final location = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _currentLocation = location;
        _loadingLocation = false;
      });

      _mapController.move(
        location,
        7.5,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loadingLocation = false;
      });
    }
  }

  // ============================================================
  // LOAD RAINVIEWER RADAR DATA
  // ============================================================

  Future<void> _loadRadarData() async {
    if (!mounted) return;

    setState(() {
      _loadingRadar = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.rainviewer.com/public/weather-maps.json',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Radar API returned ${response.statusCode}',
        );
      }

      final Map<String, dynamic> data =
      jsonDecode(response.body);

      final String host =
          data['host']?.toString() ?? '';

      final radar =
      data['radar'] as Map<String, dynamic>?;

      if (host.isEmpty || radar == null) {
        throw Exception(
          'Invalid radar API response.',
        );
      }

      final List<RadarFrame> frames = [];

      // ----------------------------------------------------------
      // PAST RADAR FRAMES
      // ----------------------------------------------------------

      final past =
          radar['past'] as List<dynamic>? ?? [];

      for (final item in past) {
        final frame =
        item as Map<String, dynamic>;

        final path =
        frame['path']?.toString();

        final time =
        frame['time'];

        if (path == null || time == null) {
          continue;
        }

        frames.add(
          RadarFrame(
            time: int.tryParse(
              time.toString(),
            ) ??
                0,
            tileUrl:
            _buildRadarTileUrl(
              host,
              path,
            ),
          ),
        );
      }

      // ----------------------------------------------------------
      // NOWCAST FRAMES
      // ----------------------------------------------------------

      final nowcast =
      radar['nowcast'] as List<dynamic>?;

      if (nowcast != null) {
        for (final item in nowcast) {
          final frame =
          item as Map<String, dynamic>;

          final path =
          frame['path']?.toString();

          final time =
          frame['time'];

          if (path == null || time == null) {
            continue;
          }

          frames.add(
            RadarFrame(
              time: int.tryParse(
                time.toString(),
              ) ??
                  0,
              tileUrl:
              _buildRadarTileUrl(
                host,
                path,
              ),
            ),
          );
        }
      }

      frames.sort(
            (a, b) => a.time.compareTo(b.time),
      );

      if (frames.isEmpty) {
        throw Exception(
          'No radar frames available.',
        );
      }

      if (!mounted) return;

      setState(() {
        _radarFrames = frames;
        _selectedFrame =
            frames.length - 1;
        _loadingRadar = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingRadar = false;
        _errorMessage =
        'Unable to load radar data.';
      });
    }
  }

  // ============================================================
  // BUILD RADAR TILE URL
  // ============================================================

  String _buildRadarTileUrl(
      String host,
      String path,
      ) {
    return '$host$path/256/{z}/{x}/{y}/2/1_1.png';
  }

  // ============================================================
  // PLAY RADAR ANIMATION
  // ============================================================

  void _toggleAnimation() {
    if (_radarFrames.isEmpty) {
      return;
    }

    if (_isPlaying) {
      _stopAnimation();
      return;
    }

    setState(() {
      _isPlaying = true;
    });

    _animationTimer = Timer.periodic(
      const Duration(milliseconds: 700),
          (_) {
        if (!mounted ||
            _radarFrames.isEmpty) {
          return;
        }

        setState(() {
          _selectedFrame++;

          if (_selectedFrame >=
              _radarFrames.length) {
            _selectedFrame = 0;
          }
        });
      },
    );
  }

  void _stopAnimation() {
    _animationTimer?.cancel();
    _animationTimer = null;

    if (!mounted) return;

    setState(() {
      _isPlaying = false;
    });
  }

  // ============================================================
  // MOVE TO CURRENT LOCATION
  // ============================================================

  Future<void> _goToCurrentLocation() async {
    await _getCurrentLocation();

    if (!mounted) return;

    _mapController.move(
      _currentLocation,
      8.5,
    );
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatFrameTime(
      int unixTime,
      ) {
    if (unixTime == 0) {
      return '--:--';
    }

    final date =
    DateTime.fromMillisecondsSinceEpoch(
      unixTime * 1000,
      isUtc: true,
    ).toLocal();

    final hour =
    date.hour.toString().padLeft(2, '0');

    final minute =
    date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final hasRadar =
        _radarFrames.isNotEmpty;

    return Scaffold(
      backgroundColor:
      const Color(0xFF101F58),

      appBar: AppBar(
        backgroundColor:
        const Color(0xFF080F68),

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
          'Radar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            onPressed: _loadRadarData,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
        ],
      ),

      body: Stack(
        children: [

          // ======================================================
          // MAP
          // ======================================================

          FlutterMap(
            mapController: _mapController,

            options: MapOptions(
              initialCenter:
              _currentLocation,

              initialZoom: 7.5,

              minZoom: 3,
              maxZoom: 12,

              interactionOptions:
              const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),

            children: [

              // --------------------------------------------------
              // BASE MAP
              // --------------------------------------------------

              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                userAgentPackageName:
                'com.example.weather_forcast',

                maxZoom: 19,
              ),

              // --------------------------------------------------
              // RADAR OVERLAY
              // --------------------------------------------------

              if (hasRadar)
                TileLayer(
                  key: ValueKey(
                    _radarFrames[
                    _selectedFrame]
                        .tileUrl,
                  ),

                  urlTemplate:
                  _radarFrames[
                  _selectedFrame]
                      .tileUrl,

                  tileDisplay:
                  const TileDisplay.fadeIn(),

                  maxZoom: 7,

                  tileProvider:
                  NetworkTileProvider(),
                ),

              // --------------------------------------------------
              // USER LOCATION
              // --------------------------------------------------

              MarkerLayer(
                markers: [
                  Marker(
                    point:
                    _currentLocation,

                    width: 50,
                    height: 50,

                    child: Container(
                      decoration:
                      BoxDecoration(
                        color: Colors.blue
                            .withOpacity(
                          0.20,
                        ),
                        shape:
                        BoxShape.circle,
                        border:
                        Border.all(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),

                      child:
                      const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ======================================================
          // LOADING
          // ======================================================

          if (_loadingRadar ||
              _loadingLocation)
            const Center(
              child:
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ),

          // ======================================================
          // ERROR
          // ======================================================

          if (_errorMessage != null)
            Positioned(
              top: 15,
              left: 15,
              right: 15,
              child: Container(
                padding:
                const EdgeInsets.all(12),

                decoration:
                BoxDecoration(
                  color: Colors.black87,
                  borderRadius:
                  BorderRadius.circular(10),
                ),

                child: Row(
                  children: [

                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style:
                        const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed:
                      _loadRadarData,
                      icon:
                      const Icon(
                        Icons.refresh,
                        color:
                        Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ======================================================
          // LOCATION BUTTON
          // ======================================================

          Positioned(
            right: 15,
            bottom: 175,
            child: FloatingActionButton.small(
              heroTag: 'radar_location',

              backgroundColor:
              Colors.white,

              onPressed:
              _goToCurrentLocation,

              child: const Icon(
                Icons.my_location,
                color: Color(
                  0xFF0F2B5B,
                ),
              ),
            ),
          ),

          // ======================================================
          // RADAR CONTROL PANEL
          // ======================================================

          if (hasRadar)
            Positioned(
              left: 10,
              right: 10,
              bottom: 15,
              child:
              _buildRadarControls(),
            ),

          // ======================================================
          // RAINVIEWER CREDIT
          // ======================================================

          Positioned(
            left: 10,
            top: 10,
            child: Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),

              decoration:
              BoxDecoration(
                color: Colors.black54,
                borderRadius:
                BorderRadius.circular(5),
              ),

              child: const Text(
                'Weather data by RainViewer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RADAR CONTROLS
  // ============================================================

  Widget _buildRadarControls() {
    final frame =
    _radarFrames[_selectedFrame];

    return Container(
      padding:
      const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        10,
      ),

      decoration: BoxDecoration(
        color: const Color(
          0xEE101F58,
        ),

        borderRadius:
        BorderRadius.circular(14),

        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black38,
          ),
        ],
      ),

      child: Column(
        mainAxisSize:
        MainAxisSize.min,

        children: [

          // ------------------------------------------------------
          // TIME
          // ------------------------------------------------------

          Row(
            children: [

              const Icon(
                Icons.radar,
                color: Colors.white,
                size: 20,
              ),

              const SizedBox(
                width: 8,
              ),

              const Expanded(
                child: Text(
                  'Precipitation Radar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),

              Text(
                _formatFrameTime(
                  frame.time,
                ),
                style:
                const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 5,
          ),

          // ------------------------------------------------------
          // TIMELINE
          // ------------------------------------------------------

          Slider(
            value: _selectedFrame
                .toDouble(),

            min: 0,

            max: (_radarFrames.length - 1)
                .toDouble(),

            activeColor:
            Colors.lightBlueAccent,

            inactiveColor:
            Colors.white24,

            onChanged: (value) {
              _stopAnimation();

              setState(() {
                _selectedFrame =
                    value.round();
              });
            },
          ),

          // ------------------------------------------------------
          // BUTTONS
          // ------------------------------------------------------

          Row(
            children: [

              IconButton(
                onPressed: () {
                  _stopAnimation();

                  setState(() {
                    if (_selectedFrame > 0) {
                      _selectedFrame--;
                    }
                  });
                },

                icon: const Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                ),
              ),

              Expanded(
                child: Center(
                  child:
                  IconButton(
                    onPressed:
                    _toggleAnimation,

                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,

                      color:
                      Colors.white,

                      size: 42,
                    ),
                  ),
                ),
              ),

              IconButton(
                onPressed: () {
                  _stopAnimation();

                  setState(() {
                    if (_selectedFrame <
                        _radarFrames.length -
                            1) {
                      _selectedFrame++;
                    }
                  });
                },

                icon: const Icon(
                  Icons.skip_next,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================================================================
// RADAR FRAME MODEL
// ================================================================

class RadarFrame {
  final int time;
  final String tileUrl;

  const RadarFrame({
    required this.time,
    required this.tileUrl,
  });
}

