import 'package:flutter/material.dart';
import '../services/route_service.dart';
import '../services/warehouse_service.dart';
import '../models/route.dart';
import '../models/warehouse.dart';
import '../widgets/main_drawer.dart';

class RouteListScreen extends StatefulWidget {
  const RouteListScreen({super.key});

  @override
  State<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  final RouteService _service = RouteService();
  List<ShipRoute> _data = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await _service.getRoutes();
    setState(() {
      _data = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Rute"),
        backgroundColor: const Color(0xFF1e293b),
        foregroundColor: Colors.white,
      ),
      drawer: const MainDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _data.isEmpty
                  ? const Center(child: Text("Belum ada data rute"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _data.length,
                      itemBuilder: (context, index) {
                        final r = _data[index];
                        return _buildCard(r);
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

  Widget _buildCard(ShipRoute r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warehouse_outlined, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(child: Text(r.originName ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 7),
              child: Icon(Icons.more_vert, size: 14, color: Colors.grey),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text(r.destinationName ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("📏 ${r.distanceKm} km", style: const TextStyle(color: Colors.grey)),
                Text("⏳ ~${r.estimatedHours} jam", style: const TextStyle(color: Colors.grey)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _delete(r)),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _openForm() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RouteFormScreen()),
    );
    if (res == true) _load();
  }

  void _delete(ShipRoute r) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Hapus Rute?"),
        content: Text("Yakin ingin menghapus rute ${r.originCity} ke ${r.destinationCity}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final success = await _service.deleteRoute(r.id!);
      if (success) _load();
    }
  }
}

class RouteFormScreen extends StatefulWidget {
  const RouteFormScreen({super.key});

  @override
  State<RouteFormScreen> createState() => _RouteFormScreenState();
}

class _RouteFormScreenState extends State<RouteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final RouteService _service = RouteService();
  final WarehouseService _wService = WarehouseService();
  List<Warehouse> _warehouses = [];
  int? _originId, _destId;
  final _distCtrl = TextEditingController(), _hourCtrl = TextEditingController();
  bool _loading = true, _saving = false;

  @override
  void initState() {
    super.initState();
    _loadWarehouses();
  }

  Future<void> _loadWarehouses() async {
    final res = await _wService.getWarehouses();
    setState(() {
      _warehouses = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Rute")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      value: _originId,
                      items: _warehouses.map((w) => DropdownMenuItem(value: w.id, child: Text("${w.name} (${w.city})"))).toList(),
                      onChanged: (v) => setState(() => _originId = v),
                      decoration: const InputDecoration(labelText: "Gudang Asal"),
                      validator: (v) => v == null ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _destId,
                      items: _warehouses.map((w) => DropdownMenuItem(value: w.id, child: Text("${w.name} (${w.city})"))).toList(),
                      onChanged: (v) => setState(() => _destId = v),
                      decoration: const InputDecoration(labelText: "Gudang Tujuan"),
                      validator: (v) => v == null ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(controller: _distCtrl, decoration: const InputDecoration(labelText: "Jarak (km)"), keyboardType: TextInputType.number),
                    TextFormField(controller: _hourCtrl, decoration: const InputDecoration(labelText: "Estimasi Waktu (jam)"), keyboardType: TextInputType.number),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1a56db), foregroundColor: Colors.white),
                        child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text("SIMPAN"),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final r = ShipRoute(
      originWarehouseId: _originId!,
      destinationWarehouseId: _destId!,
      distanceKm: double.tryParse(_distCtrl.text),
      estimatedHours: int.tryParse(_hourCtrl.text),
    );
    final success = await _service.createRoute(r);
    if (success && mounted) Navigator.pop(context, true);
    else setState(() => _saving = false);
  }
}
