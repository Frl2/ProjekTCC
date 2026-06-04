import 'package:flutter/material.dart';
import '../services/warehouse_service.dart';
import '../models/warehouse.dart';
import '../widgets/main_drawer.dart';

class WarehouseListScreen extends StatefulWidget {
  const WarehouseListScreen({super.key});

  @override
  State<WarehouseListScreen> createState() => _WarehouseListScreenState();
}

class _WarehouseListScreenState extends State<WarehouseListScreen> {
  final WarehouseService _service = WarehouseService();
  List<Warehouse> _data = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await _service.getWarehouses();
    setState(() {
      _data = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Gudang"),
        backgroundColor: const Color(0xFF1e293b),
        foregroundColor: Colors.white,
      ),
      drawer: const MainDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _data.isEmpty
                  ? const Center(child: Text("Belum ada data gudang"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _data.length,
                      itemBuilder: (context, index) {
                        final w = _data[index];
                        return _buildCard(w);
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

  Widget _buildCard(Warehouse w) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(w.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("🏙️ ${w.city}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(w.address ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 4),
            Text("📍 ${w.latitude}, ${w.longitude}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _openForm(w)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(w)),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _openForm(Warehouse? w) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WarehouseFormScreen(warehouse: w)),
    );
    if (res == true) _load();
  }

  void _delete(Warehouse w) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Hapus Gudang?"),
        content: Text("Yakin ingin menghapus ${w.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final success = await _service.deleteWarehouse(w.id!);
      if (success) _load();
    }
  }
}

class WarehouseFormScreen extends StatefulWidget {
  final Warehouse? warehouse;
  const WarehouseFormScreen({super.key, this.warehouse});

  @override
  State<WarehouseFormScreen> createState() => _WarehouseFormScreenState();
}

class _WarehouseFormScreenState extends State<WarehouseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final WarehouseService _service = WarehouseService();
  late TextEditingController _nameCtrl, _cityCtrl, _addrCtrl, _latCtrl, _lonCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.warehouse?.name);
    _cityCtrl = TextEditingController(text: widget.warehouse?.city);
    _addrCtrl = TextEditingController(text: widget.warehouse?.address);
    _latCtrl = TextEditingController(text: widget.warehouse?.latitude?.toString());
    _lonCtrl = TextEditingController(text: widget.warehouse?.longitude?.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.warehouse == null ? "Tambah Gudang" : "Edit Gudang")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Nama Gudang"), validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
              TextFormField(controller: _cityCtrl, decoration: const InputDecoration(labelText: "Kota"), validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
              TextFormField(controller: _addrCtrl, decoration: const InputDecoration(labelText: "Alamat"), maxLines: 2),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _latCtrl, decoration: const InputDecoration(labelText: "Latitude"), keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(controller: _lonCtrl, decoration: const InputDecoration(labelText: "Longitude"), keyboardType: TextInputType.number)),
                ],
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
    final w = Warehouse(
      name: _nameCtrl.text,
      city: _cityCtrl.text,
      address: _addrCtrl.text,
      latitude: double.tryParse(_latCtrl.text),
      longitude: double.tryParse(_lonCtrl.text),
    );
    bool success;
    if (widget.warehouse == null) success = await _service.createWarehouse(w);
    else success = await _service.updateWarehouse(widget.warehouse!.id!, w);

    if (success && mounted) Navigator.pop(context, true);
    else setState(() => _saving = false);
  }
}
