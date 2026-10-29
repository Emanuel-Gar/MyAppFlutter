import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/job_task.dart';
import '../widgets/te_ayudo_app_bar.dart';
import 'job_detail_screen.dart';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  String _selectedLocation = "Tlaxcala y Puebla (Zona de prueba)";
  String _selectedCategory = "Todos";

  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  String _locationMessage = 'Buscando tu ubicación...';
  bool _mapReady = false;
  bool _hasCenteredOnLocation = false;
  StreamSubscription<Position>? _positionSubscription;

  final List<String> _categories = [
    "Todos",
    "Ayudante general",
    "Pintor",
    "Plomería",
    "Electricista",
    "Carpintero",
    "Limpieza",
    "Ayuda rápida",
  ];

  // Datos mock simulados del backend / base de datos geolocalizada
  final List<JobTask> _tasks = [
    JobTask(
      id: "1",
      title: "Reparación de tubería de baño",
      category: "Plomería",
      description: "Se requiere plomero para revisar fuga menor debajo del lavabo principal.",
      schedule: "Hoy, 15:00 hrs (aprox. 1h)",
      payment: 350.0,
      distance: "0.8 km",
      type: TaskType.oficio,
      latitude: 19.319,
      longitude: -98.239,
    ),
    JobTask(
      id: "2",
      title: "Ayuda para cargar cajas en mudanza corta",
      category: "Ayuda rápida",
      description: "Necesito apoyo para subir 5 cajas pesadas al segundo piso.",
      schedule: "Mañana, 10:00 hrs",
      payment: 250.0,
      distance: "1.2 km",
      type: TaskType.ayudaRapida,
      latitude: 19.325,
      longitude: -98.245,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Definición de colores según el documento (Azules base, Verde para éxito/botones, etc.)[cite: 2]
    final primaryColor = isDarkMode
        ? const Color(0xFF12202E)
        : const Color(0xFF1976D2);
    final backgroundColor = isDarkMode
        ? const Color(0xFF0C1620)
        : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF12202E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const TeAyudoAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // 1. ENCABEZADO Y CONTROLES SUPERIORES
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: cardColor,
              child: Column(
                children: [
                  // Barra de Ubicación Actual editable[cite: 2]
                  InkWell(
                    onTap: () {
                      // TODO: Abrir selector o edición de ubicación
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white10
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedLocation,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Barra de búsqueda libre + Botón historial/lista[cite: 2]
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "¿En qué necesitas ayuda?",
                            hintStyle: const TextStyle(fontSize: 14),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: isDarkMode
                                ? Colors.white10
                                : Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.list_alt, color: Colors.white),
                          onPressed: () => _showBottomSheetResults(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. BARRA HORIZONTAL DE CATEGORÍAS (Estilo Delivery)[cite: 2]
            Container(
              color: cardColor,
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: Colors.blue,
                      backgroundColor: cardColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : textColor,
                        fontSize: 13,
                      ),
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                    ),
                  );
                },
              ),
            ),

            // 3. MAPA VISUAL INTERACTIVO CON MARCADORES
            Expanded(
              child: Stack(
                children: [
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
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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

                  // Botón flotante para ver lista de resultados rápidos inferiores[cite: 2]
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF2E7D32,
                        ), // Color verde para botones importantes[cite: 2]
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.near_me),
                      label: const Text(
                        "Ver solicitudes y oficios cercanos",
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () => _showBottomSheetResults(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPin(
    BuildContext context, {
    required String title,
    required Color color,
    required JobTask task,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JobDetailScreen(task: task)),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4),
              ],
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(Icons.location_on, color: Colors.redAccent, size: 36),
        ],
      ),
    );
  }

  void _showBottomSheetResults(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Trabajos y ayudas cercanas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: task.type == TaskType.oficio
                            ? Colors.blue.shade100
                            : Colors.orange.shade100,
                        child: Icon(
                          task.type == TaskType.oficio
                              ? Icons.build
                              : Icons.task_alt,
                          color: task.type == TaskType.oficio
                              ? Colors.blue
                              : Colors.orange,
                        ),
                      ),
                      title: Text(
                        task.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${task.category} • ${task.distance}\n${task.schedule}",
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        "\$${task.payment.toStringAsFixed(0)} MXN",
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context); // Cierra bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobDetailScreen(task: task),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
