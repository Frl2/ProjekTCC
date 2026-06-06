import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../services/shipment_service.dart';
import '../models/shipment.dart';
import '../widgets/main_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardService _dashboardService = DashboardService();
  final ShipmentService _shipmentService = ShipmentService();
  Map<String, dynamic>? _stats;
  List<Shipment> _recentShipments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final stats = await _dashboardService.getStats();
    final shipments = await _shipmentService.getShipments();
    setState(() {
      _stats = stats;
      _recentShipments = shipments.take(5).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xFF1e293b),
        foregroundColor: Colors.white,
      ),
      drawer: const MainDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    const Text(
                      "📋 Pengiriman Terbaru",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildRecentShipments(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard('Total Pengiriman', _stats?['total_shipments']?.toString() ?? '0', Icons.inventory, Colors.orange),
        _buildStatCard('Pengiriman Aktif', _stats?['active_shipments']?.toString() ?? '0', Icons.route, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                Icon(icon, color: color.withOpacity(0.3), size: 28),
              ],
            ),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentShipments() {
    if (_recentShipments.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text("Belum ada pengiriman")),
        ),
      );
    }
    return Column(
      children: _recentShipments.map((s) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(s.trackingNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text("${s.originCity} → ${s.destCity}\n${s.senderName} → ${s.receiverName}"),
          trailing: _buildStatusBadge(s.status),
          isThreeLine: true,
        ),
      )).toList(),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'DELIVERED') color = Colors.green;
    if (status == 'PENDING') color = Colors.orange;
    if (status.contains('DELIVERY')) color = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
