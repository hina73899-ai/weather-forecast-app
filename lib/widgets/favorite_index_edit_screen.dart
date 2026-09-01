import 'package:flutter/material.dart';

class IndexItem {
  final String id;
  final String title;
  final IconData icon;
  final Color activeColor;

  IndexItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.activeColor,
  });
}

class FavoriteIndexEditScreen extends StatefulWidget {
  final List<String> initialSelectedIds;

  const FavoriteIndexEditScreen({
    super.key,
    this.initialSelectedIds = const ['rain', 'uv', 'realfeel'],
  });

  @override
  State<FavoriteIndexEditScreen> createState() => _FavoriteIndexEditScreenState();
}

class _FavoriteIndexEditScreenState extends State<FavoriteIndexEditScreen> {
  late List<String> selectedIds;

  final List<IndexItem> allParameters = [
    IndexItem(id: 'rain', title: 'Rain/snow', icon: Icons.umbrella_outlined, activeColor: const Color(0xFF007AFF)),
    IndexItem(id: 'realfeel', title: 'RealFeel', icon: Icons.thermostat_outlined, activeColor: const Color(0xFF00838F)),
    IndexItem(id: 'wind', title: 'Wind speed', icon: Icons.air, activeColor: const Color(0xFF4A148C)),
    IndexItem(id: 'uv', title: 'UV Index', icon: Icons.wb_sunny_outlined, activeColor: const Color(0xFF4CAF50)),
    IndexItem(id: 'dew', title: 'Dew point', icon: Icons.thermostat_auto, activeColor: const Color(0xFF00ACC1)),
    IndexItem(id: 'humidity', title: 'Humidity', icon: Icons.water_drop_outlined, activeColor: const Color(0xFF1E88E5)),
    IndexItem(id: 'cloud', title: 'Cloud cover', icon: Icons.cloud_outlined, activeColor: const Color(0xFF5C6BC0)),
    IndexItem(id: 'pressure', title: 'Pressure', icon: Icons.speed_outlined, activeColor: const Color(0xFF26A69A)),
    IndexItem(id: 'aqi', title: 'AQI', icon: Icons.coronavirus_outlined, activeColor: const Color(0xFF8D6E63)),
    IndexItem(id: 'precip', title: 'Precipitation', icon: Icons.thunderstorm_outlined, activeColor: const Color(0xFF3F51B5)),
    IndexItem(id: 'sunrise', title: 'Sunrise', icon: Icons.wb_twilight, activeColor: const Color(0xFFFFA726)),
    IndexItem(id: 'sunset', title: 'Sunset', icon: Icons.wb_twilight_sharp, activeColor: const Color(0xFFFF7043)),
  ];

  @override
  void initState() {
    super.initState();
    selectedIds = List.from(widget.initialSelectedIds);
  }

  void _toggleParameter(String id) {
    setState(() {
      if (selectedIds.contains(id)) {
        if (selectedIds.length > 1) {
          selectedIds.remove(id);
        }
      } else {
        if (selectedIds.length < 3) {
          selectedIds.add(id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedItems = allParameters.where((item) => selectedIds.contains(item.id)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.check, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context, selectedIds),
        ),
        title: const Text(
          "Favorite index",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Selected parameters (${selectedIds.length})",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Row(
                  children: [
                    Icon(Icons.swap_vert, color: Colors.white54, size: 16),
                    SizedBox(width: 4),
                    Text("Sort", style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1D2235),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: selectedItems.map((item) {
                  return Expanded(
                    child: Container(
                      height: 90,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item.activeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(item.icon, color: Colors.white, size: 22),
                              const Icon(Icons.arrow_forward, color: Colors.white70, size: 12),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("--", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              Text(item.title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Weather's parameters",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Parameters Selection Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: allParameters.length,
              itemBuilder: (context, index) {
                final param = allParameters[index];
                final isSelected = selectedIds.contains(param.id);

                return GestureDetector(
                  onTap: () => _toggleParameter(param.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : const Color(0xFF1D2235),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF00838F) : Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            param.icon,
                            color: isSelected ? Colors.white : Colors.white70,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            param.title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? Colors.black87 : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
            const Text(
              "Quick config for you",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),

            _QuickConfigTile(title: "•  General Public (Daily Activities)"),
            _QuickConfigTile(title: "•  Skincare enthusiasts or outdoor activities"),
            _QuickConfigTile(title: "•  Travelers, cyclists, and long-distance drivers"),
          ],
        ),
      ),
    );
  }
}

class _QuickConfigTile extends StatelessWidget {
  final String title;
  const _QuickConfigTile({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D2235),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
    );
  }
}