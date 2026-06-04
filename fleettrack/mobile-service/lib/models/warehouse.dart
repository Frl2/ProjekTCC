class Warehouse {
  final int? id;
  final String name;
  final String city;
  final String? address;
  final double? latitude;
  final double? longitude;

  Warehouse({
    this.id,
    required this.name,
    required this.city,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'],
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      address: json['address'],
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
