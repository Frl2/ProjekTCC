import 'package:flutter/material.dart';
import '../services/shipment_service.dart';
import '../models/shipment.dart';
import 'shipment_detail_screen.dart';
import 'shipment_form_screen.dart';
import '../widgets/main_drawer.dart';

class ShipmentListScreen extends StatefulWidget {
  const ShipmentListScreen({super.key});

  @override
  State<ShipmentListScreen> createState() => _ShipmentListScreenState();
}

class _ShipmentListScreenState extends State<ShipmentListScreen> {
  final ShipmentService _service = ShipmentService();
  List<Shipment> _data = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await _service.getShipments();
    setState(() {
      _data = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Manajemen Pengiriman"),
        backgroundColor: const Color(0xFF1e293b),
        foregroundColor: Colors.white,
      ),
      drawer: const MainDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _data.isEmpty
                  ? const Center(child: Text("Belum ada pengiriman"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _data.length,
                      itemBuilder: (context, index) {
                        final s = _data[index];
                        return _buildCard(s);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFF1a56db),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCard(Shipment s) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShipmentDetailScreen(shipmentId: s.id))),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                    child: Text(s.trackingNumber, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  _buildStatusBadge(s.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(s.senderName ?? '-', style: const TextStyle(fontSize: 14)),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, size: 14, color: Colors.grey)),
                  Text(s.receiverName ?? '-', style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 4),
              Text("🏙️ ${s.originCity} → ${s.destCity}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(s.driverName ?? 'Driver belum ditentukan', style: TextStyle(color: s.driverName == null ? Colors.red : Colors.grey[700], fontSize: 12)),
                  const Spacer(),
                  const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(s.createdAt?.split('T')[0] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              )
            ],
          ),
        ),
      ),
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
      child: Text(status.replaceAll('_', ' '), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _openForm() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShipmentFormScreen()),
    );
    if (res == true) _load();
  }
}
