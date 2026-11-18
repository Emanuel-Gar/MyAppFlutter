import 'dart:typed_data';

class PublicJobData {
  final String serviceType;
  final String description;
  final String payment;
  final double latitude;
  final double longitude;
  final Uint8List photoBytes;
  final String photoName;

  const PublicJobData({
    required this.serviceType,
    required this.description,
    required this.payment,
    required this.latitude,
    required this.longitude,
    required this.photoBytes,
    required this.photoName,
  });
}

final List<PublicJobData> publicJobs = [];
