import 'package:flutter/material.dart';
import '../services/driver_service.dart';
import '../models/driver.dart';
import '../widgets/main_drawer.dart';

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  final DriverService _service = DriverService();
  List<Driver> _data = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await _service.getDrivers();
    setState(() {
      _data = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Driver"),
        backgroundColor: const Color(0xFF1e293b),
        foregroundColor: Colors.white,
      ),
      drawer: const MainDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _data.isEmpty
                  ? const Center(child: Text("Belum ada data driver"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _data.length,
                      itemBuilder: (context, index) {
                        final d = _data[index];
                        return _buildCard(d);
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

  Widget _buildCard(Driver d) {
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
                Text(d.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildStatusBadge(d.status),
              ],
            ),
            const SizedBox(height: 8),
            Text("📞 ${d.phone ?? '-'}", style: const TextStyle(color: Colors.grey)),
            Text("SIM: ${d.licenseNumber ?? '-'}"),
            Text("Berlaku: ${d.licenseExpiry ?? '-'}"),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _openForm(d)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(d)),
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

  void _openForm(Driver? d) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DriverFormScreen(driver: d)),
    );
    if (res == true) _load();
  }

  void _delete(Driver d) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Hapus Driver?"),
        content: Text("Yakin ingin menghapus ${d.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final success = await _service.deleteDriver(d.id!);
      if (success) _load();
    }
  }
}

class DriverFormScreen extends StatefulWidget {
  final Driver? driver;
  const DriverFormScreen({super.key, this.driver});

  @override
  State<DriverFormScreen> createState() => _DriverFormScreenState();
}

class _DriverFormScreenState extends State<DriverFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DriverService _service = DriverService();
  late TextEditingController _nameCtrl, _phoneCtrl, _simCtrl, _expiryCtrl;
  String _status = 'available';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.driver?.name);
    _phoneCtrl = TextEditingController(text: widget.driver?.phone);
    _simCtrl = TextEditingController(text: widget.driver?.licenseNumber);
    _expiryCtrl = TextEditingController(text: widget.driver?.licenseExpiry);
    _status = widget.driver?.status ?? 'available';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.driver == null ? "Tambah Driver" : "Edit Driver")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Nama Lengkap"), validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
              TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: "Nomor Telepon")),
              TextFormField(controller: _simCtrl, decoration: const InputDecoration(labelText: "Nomor SIM")),
              TextFormField(controller: _expiryCtrl, decoration: const InputDecoration(labelText: "Berlaku Sampai (YYYY-MM-DD)"), keyboardType: TextInputType.datetime),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['available', 'on_trip', 'off', 'inactive'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
    final d = Driver(
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      licenseNumber: _simCtrl.text,
      licenseExpiry: _expiryCtrl.text,
      status: _status,
    );
    bool success;
    if (widget.driver == null) success = await _service.createDriver(d);
    else success = await _service.updateDriver(widget.driver!.id!, d);

    if (success && mounted) Navigator.pop(context, true);
    else setState(() => _saving = false);
  }
}
