import 'package:flutter/material.dart';
import '../services/shipment_service.dart';
import '../services/route_service.dart';
import '../services/vehicle_service.dart';
import '../services/driver_service.dart';
import '../models/route.dart';
import '../models/vehicle.dart';
import '../models/driver.dart';

class ShipmentFormScreen extends StatefulWidget {
  const ShipmentFormScreen({super.key});

  @override
  State<ShipmentFormScreen> createState() => _ShipmentFormScreenState();
}

class _ShipmentFormScreenState extends State<ShipmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ShipmentService _service = ShipmentService();
  final RouteService _rService = RouteService();
  final VehicleService _vService = VehicleService();
  final DriverService _dService = DriverService();

  List<ShipRoute> _routes = [];
  List<Vehicle> _vehicles = [];
  List<Driver> _drivers = [];
  bool _loading = true, _saving = false;

  int? _routeId, _vehicleId, _driverId;
  final _senderCtrl = TextEditingController(), _receiverCtrl = TextEditingController(), 
        _phoneCtrl = TextEditingController(), _addrCtrl = TextEditingController(),
        _weightCtrl = TextEditingController(), _descCtrl = TextEditingController(),
        _dateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      _rService.getRoutes(),
      _vService.getVehicles(),
      _dService.getDrivers(),
    ]);
    setState(() {
      _routes = results[0] as List<ShipRoute>;
      _vehicles = (results[1] as List<Vehicle>).where((v) => v.status == 'available').toList();
      _drivers = (results[2] as List<Driver>).where((d) => d.status == 'available').toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Pengiriman")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Logistik"),
                    DropdownButtonFormField<int>(
                      value: _routeId,
                      items: _routes.map((r) => DropdownMenuItem(value: r.id, child: Text("${r.originCity} → ${r.destinationCity}"))).toList(),
                      onChanged: (v) => setState(() => _routeId = v),
                      decoration: const InputDecoration(labelText: "Pilih Rute"),
                      validator: (v) => v == null ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _vehicleId,
                            items: _vehicles.map((v) => DropdownMenuItem(value: v.id, child: Text(v.licensePlate))).toList(),
                            onChanged: (v) => setState(() => _vehicleId = v),
                            decoration: const InputDecoration(labelText: "Kendaraan"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _driverId,
                            items: _drivers.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                            onChanged: (v) => setState(() => _driverId = v),
                            decoration: const InputDecoration(labelText: "Driver"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dateCtrl,
                      decoration: const InputDecoration(labelText: "Tanggal Jadwal (YYYY-MM-DD)", prefixIcon: Icon(Icons.calendar_today, size: 16)),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
                        if (picked != null) _dateCtrl.text = picked.toString().split(' ')[0];
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Informasi Pengirim & Penerima"),
                    TextFormField(controller: _senderCtrl, decoration: const InputDecoration(labelText: "Nama Pengirim"), validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
                    const SizedBox(height: 12),
                    TextFormField(controller: _receiverCtrl, decoration: const InputDecoration(labelText: "Nama Penerima"), validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
                    TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: "Telepon Penerima"), keyboardType: TextInputType.phone),
                    TextFormField(controller: _addrCtrl, decoration: const InputDecoration(labelText: "Alamat Penerima"), maxLines: 2),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Detail Barang"),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _weightCtrl, decoration: const InputDecoration(labelText: "Berat (kg)"), keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                    TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: "Deskripsi Barang"), maxLines: 2),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1a56db), foregroundColor: Colors.white),
                        child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text("BUAT PENGIRIMAN"),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13)),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = {
      'route_id': _routeId,
      'vehicle_id': _vehicleId,
      'driver_id': _driverId,
      'scheduled_date': _dateCtrl.text,
      'sender_name': _senderCtrl.text,
      'receiver_name': _receiverCtrl.text,
      'receiver_phone': _phoneCtrl.text,
      'receiver_address': _addrCtrl.text,
      'weight_kg': double.tryParse(_weightCtrl.text),
      'description': _descCtrl.text,
    };
    final success = await _service.createShipment(data);
    if (success && mounted) Navigator.pop(context, true);
    else setState(() => _saving = false);
  }
}
