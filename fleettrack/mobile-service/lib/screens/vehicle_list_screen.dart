import 'package:flutter/material.dart';
import '../services/vehicle_service.dart';
import '../models/vehicle.dart';
import '../widgets/main_drawer.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final VehicleService _service = VehicleService();
  List<Vehicle> _data = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await _service.getVehicles();
    setState(() {
      _data = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Armada"),
        backgroundColor: const Color(0xFF1e293b),
        foregroundColor: Colors.white,
      ),
      drawer: const MainDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _data.isEmpty
                  ? const Center(child: Text("Belum ada data armada"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _data.length,
                      itemBuilder: (context, index) {
                        final v = _data[index];
                        return _buildCard(v);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(null),
        backgroundColor: const Color(0xFF1a56db),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCard(Vehicle v) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(v.licensePlate, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildStatusBadge(v.status),
              ],
            ),
            const SizedBox(height: 8),
            Text("${v.brand ?? ''} ${v.model ?? ''}".trim(), style: const TextStyle(color: Colors.grey)),
            Text("Tipe: ${v.type}"),
            Text("Kapasitas: ${v.capacityKg?.toString() ?? '0'} kg"),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _openForm(v)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(v)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'available' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _openForm(Vehicle? v) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VehicleFormScreen(vehicle: v)),
    );
    if (res == true) _load();
  }

  void _delete(Vehicle v) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Hapus Armada?"),
        content: Text("Yakin ingin menghapus ${v.licensePlate}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final success = await _service.deleteVehicle(v.id!);
      if (success) _load();
    }
  }
}

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;
  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final VehicleService _service = VehicleService();
  late TextEditingController _plateCtrl, _typeCtrl, _brandCtrl, _modelCtrl, _yearCtrl, _capCtrl;
  String _status = 'available';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _plateCtrl = TextEditingController(text: widget.vehicle?.licensePlate);
    _typeCtrl = TextEditingController(text: widget.vehicle?.type);
    _brandCtrl = TextEditingController(text: widget.vehicle?.brand);
    _modelCtrl = TextEditingController(text: widget.vehicle?.model);
    _yearCtrl = TextEditingController(text: widget.vehicle?.year?.toString());
    _capCtrl = TextEditingController(text: widget.vehicle?.capacityKg?.toString());
    _status = widget.vehicle?.status ?? 'available';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.vehicle == null ? "Tambah Armada" : "Edit Armada")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _plateCtrl, decoration: const InputDecoration(labelText: "Nomor Polisi"), validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
              TextFormField(controller: _typeCtrl, decoration: const InputDecoration(labelText: "Tipe Kendaraan")),
              TextFormField(controller: _brandCtrl, decoration: const InputDecoration(labelText: "Merek")),
              TextFormField(controller: _modelCtrl, decoration: const InputDecoration(labelText: "Model")),
              TextFormField(controller: _yearCtrl, decoration: const InputDecoration(labelText: "Tahun"), keyboardType: TextInputType.number),
              TextFormField(controller: _capCtrl, decoration: const InputDecoration(labelText: "Kapasitas (kg)"), keyboardType: TextInputType.number),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['available', 'on_trip', 'maintenance', 'inactive'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _status = v!),
                decoration: const InputDecoration(labelText: "Status"),
              ),
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
    final v = Vehicle(
      licensePlate: _plateCtrl.text,
      type: _typeCtrl.text,
      brand: _brandCtrl.text,
      model: _modelCtrl.text,
      year: int.tryParse(_yearCtrl.text),
      capacityKg: double.tryParse(_capCtrl.text),
      status: _status,
    );
    bool success;
    if (widget.vehicle == null) {
      success = await _service.createVehicle(v);
    } else {
      success = await _service.updateVehicle(widget.vehicle!.id!, v);
    }

    if (success && mounted) {
      Navigator.pop(context, true);
    } else {
      setState(() => _saving = false);
    }
  }
}
