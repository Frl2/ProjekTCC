class Vehicle {
  final int? id;
  final String licensePlate;
  final String type;
  final String? brand;
  final String? model;
  final int? year;
  final double? capacityKg;
  final String status;

  Vehicle({
    this.id,
    required this.licensePlate,
    required this.type,
    this.brand,
    this.model,
    this.year,
    this.capacityKg,
    required this.status,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      licensePlate: json['license_plate'] ?? '',
      type: json['type'] ?? '',
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      capacityKg: json['capacity_kg'] != null ? double.parse(json['capacity_kg'].toString()) : null,
      status: json['status'] ?? 'available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'license_plate': licensePlate,
      'type': type,
      'brand': brand,
      'model': model,
      'year': year,
      'capacity_kg': capacityKg,
      'status': status,
    };
  }
}
