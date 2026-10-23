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
    const primaryBlue = Color(0xFF1976D2);
    const actionGreen = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Mi Panel",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Targeta de Perfil y Calificación
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: primaryBlue,
                      child: Icon(Icons.person, size: 36, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Emanuel García",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              SizedBox(width: 4),
                              Text(
                                "4.9",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                " (18 reseñas)",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "Identidad Verificada",
                              style: TextStyle(
                                color: actionGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Resumen Financiero / Pagos en Retención (Escrow)
            const Text(
              "Balance y Pagos",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "Ganancias Mes",
                    amount: "\$1,850.00",
                    icon: Icons.account_balance_wallet,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "En Retención",
                    amount: "\$350.00",
                    icon: Icons.lock_clock,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Mis Microturnos / Trabajos Activos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Mis Solicitudes Activas",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Ver historial",
                    style: TextStyle(color: primaryBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Item de Trabajo en Curso
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: const Icon(Icons.build, color: primaryBlue),
                ),
                title: const Text(
                  "Reparación de tubería",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Estado: En proceso • Hoy, 15:00 hrs"),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: actionGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "\$350 MXN",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Opciones Rápidas
            const Text(
              "Ajustes y Cuenta",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildOptionTile(
              Icons.verified_user,
              "Verificación de Identidad (RFC / Selfie)",
              () {},
            ),
            _buildOptionTile(
              Icons.history,
              "Historial de Trabajos Completados",
              () {},
            ),
            _buildOptionTile(
              Icons.notifications_outlined,
              "Notificaciones Push",
              () {},
            ),
            _buildOptionTile(Icons.help_outline, "Soporte y Ayuda", () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1976D2)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
