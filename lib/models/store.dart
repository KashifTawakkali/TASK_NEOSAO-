class Store {
  final String code;
  final String storeLocation;
  final String latitude;
  final String longitude;
  final String storeAddress;
  final String timezone;
  final double distance;
  final int isNearestStore;
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  Store({
    required this.code,
    required this.storeLocation,
    required this.latitude,
    required this.longitude,
    required this.storeAddress,
    required this.timezone,
    required this.distance,
    required this.isNearestStore,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      code: json['code'] ?? "", // Provide a fallback value if field is missing
      storeLocation: json['storeLocation'] ?? "",
      latitude: json['latitude'] ?? "0.0", // Fallback if latitude is missing
      longitude: json['longitude'] ?? "0.0", // Fallback if longitude is missing
      storeAddress: json['storeAddress'] ?? "",
      timezone: json['timezone'] ?? "",
      distance: json['distance'] ?? 0.0, // Fallback if distance is missing
      isNearestStore: json['isNearestStore'] ?? 0, // Default to 0 if missing
      dayOfWeek: json['dayOfWeek'] ?? "",
      startTime: json['start_time'] ?? "",
      endTime: json['end_time'] ?? "",
    );
  }
}
