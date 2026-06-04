class Driver {
  final int? id;
  final String name;
  final String? phone;
  final String? licenseNumber;
  final String? licenseExpiry;
  final String status;

  Driver({
    this.id,
    required this.name,
    this.phone,
    this.licenseNumber,
    this.licenseExpiry,
    required this.status,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      licenseNumber: json['license_number'],
      licenseExpiry: json['license_expiry'],
      status: json['status'] ?? 'available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry,
      'status': status,
    };
  }
}
