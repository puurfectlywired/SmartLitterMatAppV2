

class BleTag {
  final String id;
  final String name;
  final int? rssi;

  const BleTag({
    required this.id,
    required this.name,
    this.rssi,
  });

  factory BleTag.fromMap(Map<String, dynamic> data) {
    return BleTag(
      id: data['mac']?.toString() ??
          data['id']?.toString() ??
          '',
      name: data['name']?.toString() ?? 'RDL2640 Beacon',
      rssi: (data['rssi'] as num?)?.toInt(),
    );
  }
}