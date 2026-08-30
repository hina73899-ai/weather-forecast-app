import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../repository/location_search_repository.dart';

class LocationSearchDelegate extends SearchDelegate<LocationModel?> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFF191B26),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF191B26),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text("Type city name to search", style: TextStyle(color: Colors.white54)),
      );
    }

    return FutureBuilder<List<LocationModel>>(
      future: LocationSearchService.searchCities(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("No locations found", style: TextStyle(color: Colors.white54)),
          );
        }

        final results = snapshot.data!;
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final loc = results[index];
            return ListTile(
              leading: const Icon(Icons.location_city, color: Colors.white70),
              title: Text(loc.name, style: const TextStyle(color: Colors.white)),
              subtitle: Text(loc.country, style: const TextStyle(color: Colors.white54)),
              onTap: () => close(context, loc),
            );
          },
        );
      },
    );
  }
}