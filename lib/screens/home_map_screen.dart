import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../services/publicjob_service.dart';
import '../widgets/te_ayudo_app_bar.dart';
import 'accepted_job_screen.dart';
import 'job_detail_screen.dart';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  String _selectedCategory = "Todos";

  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  PublicJobData? _acceptedPublicJob;
  bool _isCalculatingRoute = false;
  int _routeRequestId = 0;
  final Distance _distanceCalculator = const Distance();
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

  List<PublicJobData> get _nearbyPublicJobs => publicJobs
      .where((job) => _isWithinSearchRadius(job.latitude, job.longitude))
      .toList();

  PublicJobData? _findAcceptedJob() {
    for (final job in publicJobs.reversed) {
      if (job.trabajoAceptado == 1 ||
          job.trabajoAceptado == 2 ||
          (job.trabajoAceptado == 3 && !job.paymentConfirmed)) {
        return job;
      }
    }
    return null;
  }

  bool _isWithinSearchRadius(double latitude, double longitude) {
    final currentLocation = _currentLocation;
    if (currentLocation == null) return false;
    if (!latitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        !longitude.isFinite ||
        longitude < -180 ||
        longitude > 180) {
      return false;
    }

    return _distanceCalculator.as(
          LengthUnit.Kilometer,
          currentLocation,
          LatLng(latitude, longitude),
        ) <=
        20;
  }

  String _distanceLabel(double latitude, double longitude) {
    final distance = _distanceCalculator.as(
      LengthUnit.Kilometer,
      _currentLocation!,
      LatLng(latitude, longitude),
    );
    return '${distance.toStringAsFixed(1)} km';
  }

  @override
  void initState() {
    super.initState();
    _acceptedPublicJob = _findAcceptedJob();
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

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
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
      _mapController.move(_currentLocation!, 10);
      _hasCenteredOnLocation = true;
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  void _showPublicJobDialog(PublicJobData job) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(job.serviceType),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.description),
            const SizedBox(height: 8),
            Text('Pago ofrecido: \$${job.payment} MXN'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              unawaited(_acceptPublicJob(job));
            },
            child: const Text('Aceptar trabajo'),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptPublicJob(PublicJobData job) async {
    final origin = _currentLocation;
    if (origin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se puede aceptar: no está disponible tu ubicación.',
          ),
        ),
      );
      return;
    }

    final requestId = ++_routeRequestId;
    final previousJob = _acceptedPublicJob;
    if (previousJob != null &&
        !identical(previousJob, job) &&
        previousJob.trabajoAceptado == 1) {
      previousJob.trabajoAceptado = 0;
      previousJob.estadoTrabajo = 0;
      previousJob.acceptedRoute = const [];
    }
    setState(() {
      _acceptedPublicJob = job;
      job.trabajoAceptado = 1;
      job.estadoTrabajo = 0;
      job.acceptedRoute = const [];
      _isCalculatingRoute = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calculando ruta por calles...')),
    );

    try {
      final route = await _fetchRoadRoute(
        origin,
        LatLng(job.latitude, job.longitude),
      );
      if (!mounted || requestId != _routeRequestId) return;

      job.acceptedRoute = route;
      setState(() {
        _isCalculatingRoute = false;
      });
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(route),
          padding: const EdgeInsets.all(48),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ruta por calles marcada en el mapa.')),
      );
    } on TimeoutException {
      _showRouteError(
        requestId,
        'El servicio de rutas tardó demasiado. Intenta de nuevo.',
      );
    } on http.ClientException {
      _showRouteError(
        requestId,
        'No se pudo conectar al servicio de rutas. Intenta de nuevo.',
      );
    } on FormatException {
      _showRouteError(
        requestId,
        'No se encontró una ruta para este trabajo. Intenta de nuevo.',
      );
    }
  }

  void _cancelAcceptedJob() {
    ++_routeRequestId;
    final job = _acceptedPublicJob;
    if (job != null && job.trabajoAceptado == 1) {
      job.trabajoAceptado = 0;
      job.estadoTrabajo = 0;
      job.acceptedRoute = const [];
    }
    setState(() {
      _acceptedPublicJob = null;
      _isCalculatingRoute = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trabajo cancelado. Ruta eliminada.')),
    );
  }

  void _openAcceptedJob() {
    final job = _findAcceptedJob();
    if (job == null) return;
    _acceptedPublicJob = job;

    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => AcceptedJobScreen(
          job: job,
          statusIndex: job.estadoTrabajo,
          onStatusChanged: (index) {
            if (!mounted || !identical(_acceptedPublicJob, job)) return;
            setState(() {
              job.estadoTrabajo = index;
              job.trabajoAceptado = index == 2 ? 2 : 1;
            });
          },
          onCancel: _cancelAcceptedJob,
        ),
      ),
    );
  }

  Future<List<LatLng>> _fetchRoadRoute(
    LatLng origin,
    LatLng destination,
  ) async {
    final uri = Uri.https(
      'router.project-osrm.org',
      '/route/v1/driving/${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}',
      {'overview': 'full', 'geometries': 'geojson'},
    );
    final response = await http
        .get(uri, headers: const {'User-Agent': 'teayudoapp/1.0'})
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw const FormatException('El servicio de rutas no está disponible.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['code'] != 'Ok') {
      throw const FormatException('La respuesta de rutas no es válida.');
    }
    final routes = decoded['routes'];
    if (routes is! List || routes.isEmpty) {
      throw const FormatException('No se encontró una ruta.');
    }
    final firstRoute = routes.first;
    if (firstRoute is! Map<String, dynamic>) {
      throw const FormatException('La ruta recibida no es válida.');
    }
    final geometry = firstRoute['geometry'];
    if (geometry is! Map<String, dynamic>) {
      throw const FormatException('La geometría de la ruta no es válida.');
    }
    final coordinates = geometry['coordinates'];
    if (coordinates is! List || coordinates.length < 2) {
      throw const FormatException('La ruta no contiene suficientes puntos.');
    }

    final routePoints = <LatLng>[];
    for (final coordinate in coordinates) {
      if (coordinate is! List || coordinate.length < 2) {
        throw const FormatException('Un punto de la ruta no es válido.');
      }
      final longitudeValue = coordinate[0];
      final latitudeValue = coordinate[1];
      if (longitudeValue is! num || latitudeValue is! num) {
        throw const FormatException(
          'Las coordenadas de la ruta no son válidas.',
        );
      }

      final longitude = longitudeValue.toDouble();
      final latitude = latitudeValue.toDouble();
      if (!longitude.isFinite ||
          longitude < -180 ||
          longitude > 180 ||
          !latitude.isFinite ||
          latitude < -90 ||
          latitude > 90) {
        throw const FormatException(
          'Las coordenadas de la ruta están fuera de rango.',
        );
      }
      routePoints.add(LatLng(latitude, longitude));
    }

    return [origin, ...routePoints, destination];
  }

  void _showRouteError(int requestId, String message) {
    if (!mounted || requestId != _routeRequestId) return;
    setState(() => _isCalculatingRoute = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storedAcceptedJob = _findAcceptedJob();
    final isDarkMode = theme.brightness == Brightness.dark;
    // Definición de colores según el documento (Azules base, Verde para éxito/botones, etc.)[cite: 2]
    final primaryColor = isDarkMode
        ? const Color(0xFF12202E)
        : const Color(0xFF1976D2);
    final backgroundColor = isDarkMode ? const Color(0xFF0C1620) : Colors.white;
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
                            Icons.my_location,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _locationMessage,
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
                  if (_currentLocation == null)
                    Center(
                      child: Text(
                        _locationMessage,
                        style: TextStyle(color: textColor),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentLocation!,
                        initialZoom: 10.0,
                        onMapReady: _onMapReady,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.tuempresa.app',
                        ),
                        PolylineLayer(
                          polylines: [
                            if (storedAcceptedJob != null &&
                                storedAcceptedJob.acceptedRoute.isNotEmpty)
                              Polyline(
                                points: storedAcceptedJob.acceptedRoute,
                                strokeWidth: 4,
                                color: Colors.blue,
                              ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentLocation!,
                              width: 48,
                              height: 48,
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.blue,
                                size: 40,
                              ),
                            ),
                            for (final job in _nearbyPublicJobs)
                              Marker(
                                point: LatLng(job.latitude, job.longitude),
                                width: 48,
                                height: 48,
                                child: GestureDetector(
                                  onTap: _isCalculatingRoute
                                      ? null
                                      : () => _showPublicJobDialog(job),
                                  child: const Icon(
                                    Icons.business_center,
                                    color: Colors.red,
                                    size: 36,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                  if (_isCalculatingRoute)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Calculando ruta...',
                                style: TextStyle(color: textColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Botón flotante para ver lista de resultados rápidos inferiores[cite: 2]
                  Positioned(
                    bottom: 12,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.near_me),
                            label: const Text(
                              'Ver solicitudes y trabajos',
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () => _showBottomSheetResults(context),
                          ),
                        ),
                        if (storedAcceptedJob != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1976D2),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF1976D2),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.assignment_turned_in),
                              label: const Text(
                                'Ver trabajo aceptado',
                                textAlign: TextAlign.center,
                              ),
                              onPressed: _openAcceptedJob,
                            ),
                          ),
                        ],
                      ],
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

  void _showBottomSheetResults(BuildContext context) {
    final nearbyPublicJobs = _nearbyPublicJobs;
    final pageContext = context;
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
            const SizedBox(height: 4),
            Text(
              'Dentro de 20 km de tu ubicación actual '
              '(${nearbyPublicJobs.length})',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: nearbyPublicJobs.isEmpty
                  ? const Center(
                      child: Text('No hay trabajos dentro del radio de 20 km.'),
                    )
                  : ListView(
                      children: [
                        for (final job in nearbyPublicJobs)
                          Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFFFEBEE),
                                child: Icon(
                                  Icons.business_center,
                                  color: Colors.red,
                                ),
                              ),
                              title: Text(
                                job.serviceType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${_distanceLabel(job.latitude, job.longitude)}'
                                '\n${job.description}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              isThreeLine: true,
                              trailing: Text(
                                '\$${job.payment} MXN',
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  pageContext,
                                  MaterialPageRoute(
                                    builder: (_) => JobDetailScreen(
                                      job: job,
                                      onAccept: () =>
                                          unawaited(_acceptPublicJob(job)),
                                    ),
                                  ),
                                );
                              },
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
}
