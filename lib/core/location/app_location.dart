class AppLocation {
  final double latitude;
  final double longitude;
  final double? accuracyMeters;

  const AppLocation({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
  });
}