import 'dart:typed_data';

import 'package:latlong2/latlong.dart';

class PublicJobData {
  final String serviceType;
  final String description;
  final String payment;
  final String estimatedDuration;
  final DateTime registeredAt;
  final double latitude;
  final double longitude;
  final Uint8List photoBytes;
  final String photoName;
  int trabajoAceptado;
  int estadoTrabajo;
  String? paymentMethod;
  bool paymentConfirmed;
  List<LatLng> acceptedRoute;

  PublicJobData({
    required this.serviceType,
    required this.description,
    required this.payment,
    required this.estimatedDuration,
    required this.latitude,
    required this.longitude,
    required this.photoBytes,
    required this.photoName,
    DateTime? registeredAt,
    // 0 = published, 1 = accepted, 2 = completed by worker, 3 = payment pending/confirmed
    this.trabajoAceptado = 0,
    this.estadoTrabajo = 0,
    this.paymentMethod,
    this.paymentConfirmed = false,
    this.acceptedRoute = const [],
  }) : registeredAt = registeredAt ?? DateTime.now();
}

final List<PublicJobData> publicJobs = [];
