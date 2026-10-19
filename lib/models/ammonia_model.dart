


class AmmoniaAlert {
  final String id;
  final DateTime timestamp;
  final String status;
  final double? voltage;

  const AmmoniaAlert({
    required this.id,
    required this.timestamp,
    required this.status,
    this.voltage,
  });

  factory AmmoniaAlert.fromJson(Map<String, dynamic> json) {
    return AmmoniaAlert(
      id: json['id'].toString(),
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'] as String,
      voltage: (json['voltage'] as num?)?.toDouble(),
    );
  }
}
