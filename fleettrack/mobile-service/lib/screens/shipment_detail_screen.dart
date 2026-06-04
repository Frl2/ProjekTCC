import 'package:flutter/material.dart';
import '../services/shipment_service.dart';
import '../models/shipment.dart';

class ShipmentDetailScreen extends StatefulWidget {
  final int shipmentId;
  const ShipmentDetailScreen({super.key, required this.shipmentId});

  @override
  State<ShipmentDetailScreen> createState() => _ShipmentDetailScreenState();
}

class _ShipmentDetailScreenState extends State<ShipmentDetailScreen> {
  final ShipmentService _service = ShipmentService();
  Shipment? _s;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await _service.getShipmentDetail(widget.shipmentId);
    setState(() {
      _s = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_s == null) return const Scaffold(body: Center(child: Text("Data tidak ditemukan")));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text(_s!.trackingNumber)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildInfoCard(),
            _buildTimeline(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _showUpdateStatus(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text("UPDATE STATUS LOKASI"),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1e293b),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildStatusBadge(_s!.status),
          const SizedBox(height: 12),
          Text("${_s!.originCity} → ${_s!.destCity}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(_s!.trackingNumber, style: const TextStyle(color: Colors.white70, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildRow("📦 Pengirim", _s!.senderName ?? '-'),
            _buildRow("📥 Penerima", _s!.receiverName ?? '-'),
            _buildRow("📞 Telepon", _s!.receiverPhone ?? '-'),
            _buildRow("🏠 Alamat", _s!.receiverAddress ?? '-'),
            const Divider(),
            _buildRow("🚛 Kendaraan", _s!.licensePlate ?? '-'),
            _buildRow("👤 Driver", _s!.driverName ?? '-'),
            _buildRow("⚖️ Berat", "${_s!.weightKg ?? 0} kg"),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final logs = _s!.trackingLogs ?? [];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("RIWAYAT TRACKING", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          if (logs.isEmpty) const Text("Belum ada riwayat"),
          ...logs.map((log) => _buildTimelineItem(log)).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(TrackingLog log) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Icon(Icons.circle, size: 12, color: Colors.blue),
            Container(width: 2, height: 40, color: Colors.blue.withOpacity(0.2)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(log.status.replaceAll('_', ' '), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              if (log.location != null) Text("📍 ${log.location}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              if (log.notes != null) Text(log.notes!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(log.createdAt.split('T')[0], style: const TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 16),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'DELIVERED') color = Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(status.replaceAll('_', ' '), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  void _showUpdateStatus() async {
    final res = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => UpdateStatusModal(shipment: _s!),
    );
    if (res == true) _load();
  }
}

class UpdateStatusModal extends StatefulWidget {
  final Shipment shipment;
  const UpdateStatusModal({super.key, required this.shipment});

  @override
  State<UpdateStatusModal> createState() => _UpdateStatusModalState();
}

class _UpdateStatusModalState extends State<UpdateStatusModal> {
  String _status = '';
  final _locCtrl = TextEditingController(), _noteCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.shipment.status;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Update Status & Lokasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _status,
            items: ['PENDING','PICKED_UP','ON_DELIVERY','ARRIVED_AT_WAREHOUSE','DELIVERED','CANCELLED']
                .map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' ')))).toList(),
            onChanged: (v) => setState(() => _status = v!),
            decoration: const InputDecoration(labelText: "Status Baru"),
          ),
          TextFormField(controller: _locCtrl, decoration: const InputDecoration(labelText: "Lokasi Saat Ini")),
          TextFormField(controller: _noteCtrl, decoration: const InputDecoration(labelText: "Catatan")),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text("SIMPAN PERUBAHAN"),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _save() async {
    setState(() => _saving = true);
    final success = await ShipmentService().updateStatus(widget.shipment.id, {
      'status': _status,
      'location': _locCtrl.text,
      'notes': _noteCtrl.text,
    });
    if (success && mounted) Navigator.pop(context, true);
    else setState(() => _saving = false);
  }
}
