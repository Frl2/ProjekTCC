import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/vehicle_list_screen.dart';
import '../screens/driver_list_screen.dart';
import '../screens/warehouse_list_screen.dart';
import '../screens/route_list_screen.dart';
import '../screens/shipment_list_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1e293b)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  '🚚 FleetTrack',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sistem Tracking Armada',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          _buildItem(context, Icons.dashboard, 'Dashboard', const HomeScreen()),
          _buildItem(context, Icons.local_shipping, 'Armada', const VehicleListScreen()),
          _buildItem(context, Icons.person, 'Driver', const DriverListScreen()),
          _buildItem(context, Icons.warehouse, 'Gudang', const WarehouseListScreen()),
          _buildItem(context, Icons.map, 'Rute', const RouteListScreen()),
          _buildItem(context, Icons.inventory, 'Pengiriman', const ShipmentListScreen()),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String label, Widget screen) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => screen),
        );
      },
    );
  }
}
