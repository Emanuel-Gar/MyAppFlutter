import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  String _locationMessage = 'Buscando tu ubicación...';
  bool _mapReady = false;
  bool _hasCenteredOnLocation = false;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    unawaited(_positionSubscription?.cancel());
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showLocationMessage('Activa los servicios de ubicación.');
        return;
      }
      if (!mounted) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (!mounted) return;

      if (permission == LocationPermission.denied) {
        _showLocationMessage('Permiso de ubicación denegado.');
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _showLocationMessage(
          'Permiso denegado permanentemente. Actívalo en la configuración.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      _updateCurrentLocation(position);

      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen(
            _updateCurrentLocation,
            onError: (Object error) {
              debugPrint('Error actualizando la ubicación: $error');
              _showLocationMessage('No se pudo actualizar la ubicación.');
            },
          );
    } catch (error) {
      debugPrint('Error obteniendo la ubicación: $error');
      _showLocationMessage('No se pudo obtener tu ubicación.');
    }
  }

  void _updateCurrentLocation(Position position) {
    if (!mounted) return;
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _locationMessage = 'Tu ubicación actual';
    });
    _centerOnCurrentLocation();
  }

  void _showLocationMessage(String message) {
    if (!mounted) return;
    setState(() {
      _locationMessage = message;
    });
  }

  void _onMapReady() {
    _mapReady = true;
    _centerOnCurrentLocation();
  }

  void _centerOnCurrentLocation() {
    if (_mapReady && !_hasCenteredOnLocation && _currentLocation != null) {
      _mapController.move(_currentLocation!, 15);
      _hasCenteredOnLocation = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenido')),

      body: Container(
        decoration: BoxDecoration(color: Color.fromARGB(255, 1, 75, 140)),
        child: Center(
          child: Column(
            children: [
              Text(
                '¿Buscas ayuda?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Card(
                elevation: 8,
                margin: const EdgeInsets.all(16),
                clipBehavior: Clip.antiAlias,

                child: SizedBox(
                  width: 500,
                  height: 550,

                  child: Stack(
                    children: [
                      // MAPA DENTRO DEL CARD
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: const LatLng(19.31777, -98.23846),
                          initialZoom: 13.0,
                          onMapReady: _onMapReady,
                        ),

                        children: [
                          // Capa del mapa de OpenStreetMap
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.tuempresa.app',
                          ),

                          MarkerLayer(
                            markers: [
                              if (_currentLocation != null)
                                Marker(
                                  point: _currentLocation!,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.my_location,
                                    color: Colors.blue,
                                    size: 40,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),

                      Positioned(
                        bottom: 16,
                        left: 12,
                        right: 12,
                        child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              _locationMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
