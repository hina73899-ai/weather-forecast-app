import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/response/status.dart';
import '../models/location_model.dart';
import '../view_models/location_view_model.dart';
import '../widgets/aqi.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/daily_forcast_graph_section.dart';
import '../widgets/favorite_index_section.dart';
import '../widgets/hourly_forecast_section.dart';
import '../widgets/location_search_delegate.dart';
import '../widgets/main_temperature_section.dart';
import '../widgets/moon_phase_section.dart';
import '../widgets/page_indicator_section.dart';
import '../widgets/protection.dart';
import '../widgets/today_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationViewModel>(context, listen: false)
          .fetchWeatherApi("Lahore, Pakistan", 31.5497, 74.3436);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDotTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFF191B26),
      body: SafeArea(
        child: Column(
          children: [
            // Dynamic Header Text change based on current page
            Consumer<LocationViewModel>(
              builder: (context, vm, child) => _FixedAppBar(
                cityName: _currentPage == 0 ? vm.currentCity : "Add location",
              ),
            ),

            // Figma Curved Indicator Dots
            PageIndicatorSection(
              activeIndex: _currentPage,
              totalPages: 2,
              onDotTap: _onDotTapped,
            ),

            // PageView body with explicit Physics
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // PAGE 1: Weather Screen
                  _buildWeatherPage(),

                  // PAGE 2: Add Location Screen
                  _buildAddLocationPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PAGE 1: Weather Content
  Widget _buildWeatherPage() {
    return Consumer<LocationViewModel>(
      builder: (context, value, child) {
        switch (value.weatherList.status) {
          case Status.Loading:
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          case Status.Error:
            return Center(
              child: Text(
                value.weatherList.message.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            );
          case Status.Complete:
            final weather = value.weatherList.data!;
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                const SizedBox(height: 10),
                MainTemperatureSection(
                  currentTemp: weather.currentTemp,
                ),
                const SizedBox(height: 20),

                // Favorite Section Wrapped in explicit bounds
                SizedBox(
                  width: double.infinity,
                  child: FavoriteIndexSection(weather: weather),
                ),

                const SizedBox(height: 20),
                HourlyForecastSection(hourly: weather.hourly),
                const SizedBox(height: 16),
                DailyForecastGraphSection(daily: weather.daily),
                const SizedBox(height: 16),
                const TodayDetail(),
                const SizedBox(height: 16),
                MoonPhaseSection(daily: weather.daily),
                const SizedBox(height: 16),
                const Protection(latitude: 31.5497, longitude: 74.3436),
                const SizedBox(height: 16),
                const AQI(),
                const SizedBox(height: 20),
              ],
            );
          default:
            return Container();
        }
      },
    );
  }

  // PAGE 2: Add Location UI
  Widget _buildAddLocationPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final selectedLocation = await showSearch<LocationModel?>(
                context: context,
                delegate: LocationSearchDelegate(),
              );

              if (selectedLocation != null && mounted) {
                final cityName =
                    "${selectedLocation.name}, ${selectedLocation.country}";

                Provider.of<LocationViewModel>(context, listen: false)
                    .fetchWeatherApi(
                  cityName,
                  selectedLocation.latitude,
                  selectedLocation.longitude,
                );

                _onDotTapped(0);
              }
            },
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2B2E3D),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_circle_outline,
                      color: Colors.white70, size: 24),
                  SizedBox(width: 12),
                  Text(
                    "Add location",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FixedAppBar extends StatelessWidget {
  final String cityName;
  const _FixedAppBar({required this.cityName});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF191B26),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu, color: Colors.white),
          ),
          Text(
            cityName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ],
      ),
    );
  }
}