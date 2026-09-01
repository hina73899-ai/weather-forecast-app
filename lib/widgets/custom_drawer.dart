import 'package:flutter/material.dart';

import '../utils/App-colors.dart';
import '../views/home_screen.dart';
import '../views/radar_screen.dart';
import 'location_screen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  late final double drawerWidth = MediaQuery.of(context).size.width * 0.80;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: drawerWidth,
      height: double.infinity,
      decoration:  BoxDecoration(

        gradient: LinearGradient(
          colors: [
            AppColors.drawerGradientStart,
            AppColors.drawerGradientEnd,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Drawer(
        backgroundColor: const Color(0xFF0F2B5B),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero
        ),
        child: SafeArea(
          child: ListView(
            // Bouncing scroll effect (iOS style smooth scrolling)
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              _buildDrawerItem(
                icon: Icons.home_outlined,
                title: "Home",
                onTap: () {
                  Navigator.pop(context); // Drawer close
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                },
              ),
              _buildDrawerItem(
                icon: Icons.edit_location_alt_outlined,
                title: "Edit locations",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LocationScreen()),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.radar_outlined,
                title: "Radar",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RadarScreen(),
                    ),
                  );
                },
              ),

              // General Section Header
              _buildSectionHeader("General"),

              _buildDrawerItem(
                icon: Icons.settings_outlined,
                title: "Settings",
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Add navigation to Settings screen
                },
              ),
              _buildDrawerItem(
                icon: Icons.build_outlined,
                title: "Customize",
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Add navigation
                },
              ),
              _buildDrawerItem(
                icon: Icons.grid_view_outlined,
                title: "Widgets",
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Add navigation
                },
              ),
              _buildDrawerItem(
                icon: Icons.notifications_none_outlined,
                title: "Notifications",
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Add navigation
                },
              ),
              _buildDrawerItem(
                icon: Icons.star_border_outlined,
                title: "Favorite index",
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Add navigation
                },
              ),

              // Developer Section Header
              _buildSectionHeader("Developer"),

              _buildDrawerItem(
                icon: Icons.chat_bubble_outline_rounded,
                title: "Feedback about weather app",
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Add navigation
                },
              ),
              _buildDrawerItem(
                icon: Icons.star_outline_rounded,
                title: "Rate app",
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Add navigation
                },
              ),
              _buildDrawerItem(
                icon: Icons.outlined_flag,
                title: "Report problems",
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Add navigation
                },
              ),
              _buildDrawerItem(
                icon: Icons.share_outlined,
                title: "Share this app",
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Share logic
                },
              ),
              _buildDrawerItem(
                icon: Icons.apps_outlined,
                title: "More apps",
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Add navigation
                },
              ),

              const SizedBox(height: 20),

              // App Version
              const Center(
                child: Text(
                  "Version 1.42.01",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: const Color(0xFF3B62AC), // Lighter blue accent header
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF29B6F6), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.white30,
        size: 14,
      ),
      onTap: onTap,
    );
  }
}

