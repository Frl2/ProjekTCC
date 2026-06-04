class ShipRoute {
  final int? id;
  final int originWarehouseId;
  final int destinationWarehouseId;
  final String? originName;
  final String? originCity;
  final String? destinationName;
  final String? destinationCity;
  final double? distanceKm;
  final int? estimatedHours;

  ShipRoute({
    this.id,
    required this.originWarehouseId,
    required this.destinationWarehouseId,
    this.originName,
    this.originCity,
    this.destinationName,
    this.destinationCity,
    this.distanceKm,
    this.estimatedHours,
  });

  factory ShipRoute.fromJson(Map<String, dynamic> json) {
    return ShipRoute(
      id: json['id'],
      originWarehouseId: json['origin_warehouse_id'] ?? 0,
      destinationWarehouseId: json['destination_warehouse_id'] ?? 0,
      originName: json['origin_name'],
      originCity: json['origin_city'],
      destinationName: json['destination_name'],
      destinationCity: json['destination_city'],
      distanceKm: json['distance_km'] != null ? double.parse(json['distance_km'].toString()) : null,
      estimatedHours: json['estimated_hours'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'origin_warehouse_id': originWarehouseId,
      'destination_warehouse_id': destinationWarehouseId,
      'distance_km': distanceKm,
      'estimated_hours': estimatedHours,
    };
  }
}
