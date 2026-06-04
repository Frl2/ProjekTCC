class TrackingLog {
  final int id;
  final int shipmentId;
  final String status;
  final String? location;
  final String? notes;
  final String createdAt;

  TrackingLog({
    required this.id,
    required this.shipmentId,
    required this.status,
    this.location,
    this.notes,
    required this.createdAt,
  });

  factory TrackingLog.fromJson(Map<String, dynamic> json) {
    return TrackingLog(
      id: json['id'] ?? 0,
      shipmentId: json['shipment_id'] ?? 0,
      status: json['status'] ?? '',
      location: json['location'],
      notes: json['notes'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class Shipment {
  final int id;
  final String trackingNumber;
  final String? senderName;
  final String? receiverName;
  final String? receiverPhone;
  final String? receiverAddress;
  final double? weightKg;
  final String? description;
  final String status;
  final String? originCity;
  final String? destCity;
  final String? driverName;
  final String? licensePlate;
  final String? createdAt;
  final List<TrackingLog>? trackingLogs;

  Shipment({
    required this.id,
    required this.trackingNumber,
    this.senderName,
    this.receiverName,
    this.receiverPhone,
    this.receiverAddress,
    this.weightKg,
    this.description,
    required this.status,
    this.originCity,
    this.destCity,
    this.driverName,
    this.licensePlate,
    this.createdAt,
    this.trackingLogs,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    var logsJson = json['tracking_logs'] as List?;
    List<TrackingLog>? logs = logsJson?.map((i) => TrackingLog.fromJson(i)).toList();

    return Shipment(
      id: json['id'] ?? 0,
      trackingNumber: json['tracking_number'] ?? '',
      senderName: json['sender_name'],
      receiverName: json['receiver_name'],
      receiverPhone: json['receiver_phone'],
      receiverAddress: json['receiver_address'],
      weightKg: json['weight_kg'] != null ? double.parse(json['weight_kg'].toString()) : null,
      description: json['description'],
      status: json['status'] ?? 'PENDING',
      originCity: json['origin_city'],
      destCity: json['dest_city'],
      driverName: json['driver_name'],
      licensePlate: json['license_plate'],
      createdAt: json['created_at'],
      trackingLogs: logs,
    );
  }
}
