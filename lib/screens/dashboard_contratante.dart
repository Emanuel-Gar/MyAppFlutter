import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/publicjob_service.dart';
import 'accpted_job_contratante_screen.dart';
import 'public_job_screen.dart';
import '../widgets/contratante_app_bar.dart';
import '../services/push_notification_service.dart';

class ContratanteScreen extends StatefulWidget {
  const ContratanteScreen({super.key});

  @override
  State<ContratanteScreen> createState() => _ContratanteScreenState();
}

class _ContratanteScreenState extends State<ContratanteScreen> {
  // Controla qué sección se muestra en el cuerpo principal
  String _currentSection = 'inicio';

  // Controladores para el formulario de Editar Perfil
  final _nombrePerfilController = TextEditingController(
    text: 'Contratante Cliente',
  );
  final _correoPerfilController = TextEditingController(
    text: 'contratante@teayudo.com',
  );
  final _telefonoPerfilController = TextEditingController(
    text: '+52 246 123 4567',
  );

  // Estado interactivo para Calificación de Servicios
  final List<_WorkerRatingItem> _workersToRate = [
    _WorkerRatingItem(
      id: 'w1',
      name: 'Carlos Mendoza',
      service: 'Instalación de red doméstica',
      puntualidad: 5,
      calidad: 5,
      atencion: 4,
      tiempoEntrega: 5,
    ),
    _WorkerRatingItem(
      id: 'w2',
      name: 'Jorge Luis Pérez',
      service: 'Reparación de tubería de agua',
      puntualidad: 4,
      calidad: 4,
      atencion: 5,
      tiempoEntrega: 4,
    ),
    _WorkerRatingItem(
      id: 'w3',
      name: 'Ana Sofía Ruiz',
      service: 'Soporte técnico y mantenimiento',
      puntualidad: 0,
      calidad: 0,
      atencion: 0,
      tiempoEntrega: 0,
    ),
  ];

  int _selectedWorkerIndex = 0;
  final _comentarioCalificacionController = TextEditingController();

  @override
  void dispose() {
    _nombrePerfilController.dispose();
    _correoPerfilController.dispose();
    _telefonoPerfilController.dispose();
    _comentarioCalificacionController.dispose();
    super.dispose();
  }

  Future<void> _openPublicJobScreen() async {
    final published = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PublicJobScreen()),
    );
    if (!mounted || published != true) return;

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Trabajo publicado con éxito!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _openAcceptedJobStatus(PublicJobData job) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => AcceptedJobContratanteScreen(job: job)),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1976D2);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Colores dinámicos adaptados a modo claro/oscuro
    final backgroundColor = isDarkMode
        ? const Color(0xFF121212)
        : Colors.grey[100]!;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.grey[800]!;
    final subtitleColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

    final nombreDrawer = _nombrePerfilController.text.trim().isEmpty
        ? 'Panel de Contratante'
        : _nombrePerfilController.text.trim();
    final correoDrawer = _correoPerfilController.text.trim().isEmpty
        ? 'contratante@teayudo.com'
        : _correoPerfilController.text.trim();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: ContratanteAppBar(title: _getSectionTitle()),
      // --- MENÚ DE HAMBURGUESA (DRAWER) ---
      drawer: Drawer(
        backgroundColor: cardColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: primaryBlue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: primaryBlue),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nombreDrawer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    correoDrawer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_rounded, color: primaryBlue),
              title: Text(
                'Panel Principal',
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                setState(() => _currentSection = 'inicio');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.add_circle_outline_rounded,
                color: primaryBlue,
              ),
              title: Text(
                'Publicar un trabajo',
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _openPublicJobScreen();
              },
            ),
            ListTile(
              leading: const Icon(Icons.payments_rounded, color: primaryBlue),
              title: Text(
                'Pago al trabajador',
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                setState(() => _currentSection = 'pagos');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_rate_rounded, color: primaryBlue),
              title: Text(
                'Calificación de servicios',
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                setState(() => _currentSection = 'calificaciones');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.manage_accounts_rounded,
                color: primaryBlue,
              ),
              title: Text(
                'Editar Perfil',
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                setState(() => _currentSection = 'perfil');
                Navigator.pop(context);
              },
            ),
            const Divider(),
            // --- MENÚ DESPLEGABLE PARA DISPARAR NOTIFICACIONES PUSH REALES ---
            ExpansionTile(
              leading: const Icon(
                Icons.notifications_active_rounded,
                color: Colors.orange,
              ),
              title: Text(
                'Simular Notificaciones',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              children: [
                _buildNotificationSubItem(
                  'Nuevo trabajo encontrado',
                  'Un trabajador aceptó postularse.',
                  context,
                ),
                _buildNotificationSubItem(
                  'Trabajo aceptado',
                  'El microturno ha comenzado en ruta.',
                  context,
                ),
                _buildNotificationSubItem(
                  'Trabajo finalizado',
                  'El servicio concluyó con éxito.',
                  context,
                ),
                _buildNotificationSubItem(
                  'Pago realizado',
                  'La transferencia SPEI fue exitosa.',
                  context,
                ),
              ],
            ),
          ],
        ),
      ),
      // --- CUERPO DINÁMICO SEGÚN LA SECCIÓN SELECCIONADA ---
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildBodyContent(
            primaryBlue,
            cardColor,
            textColor,
            subtitleColor,
          ),
        ),
      ),
    );
  }

  String _getSectionTitle() {
    switch (_currentSection) {
      case 'pagos':
        return 'Pagos a Trabajadores';
      case 'calificaciones':
        return 'Calificar Servicios';
      case 'perfil':
        return 'Editar Mi Perfil';
      default:
        return 'Inicio';
    }
  }

  // Elemento secundario del acordeón de notificaciones conectado al helper real
  Widget _buildNotificationSubItem(
    String title,
    String subtitle,
    BuildContext context,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: const Icon(
        Icons.notifications_active_rounded,
        size: 18,
        color: Colors.blue,
      ),
      onTap: () {
        Navigator.pop(context); // Cierra el drawer

        // Llamada a la función helper externa para enviar la notificación real del sistema
        PushNotificationService.showNotification(title: title, body: subtitle);
      },
    );
  }

  // Renderiza las vistas del cuerpo principal
  Widget _buildBodyContent(
    Color primaryBlue,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    if (_currentSection == 'pagos') {
      return _buildPaymentsView(cardColor, textColor, subtitleColor);
    } else if (_currentSection == 'calificaciones') {
      return _buildRatingsView(
        primaryBlue,
        cardColor,
        textColor,
        subtitleColor,
      );
    } else if (_currentSection == 'perfil') {
      return _buildEditProfileView(
        primaryBlue,
        cardColor,
        textColor,
        subtitleColor,
      );
    } else {
      return _buildHomeDashboard(
        primaryBlue,
        cardColor,
        textColor,
        subtitleColor,
      );
    }
  }

  // 1. Vista de Inicio / Resumen de Contratante
  Widget _buildHomeDashboard(
    Color primaryBlue,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final jobs = publicJobs;

    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, primaryBlue.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido, Contratante',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 6),
              Text(
                'Gestiona tus microturnos y pagos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: primaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.work_outline_rounded, color: primaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Trabajos publicados (${jobs.length})',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (jobs.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No hay trabajos publicados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          for (final job in jobs)
            _buildPublishedJobCard(
              job,
              primaryBlue,
              cardColor,
              textColor,
              subtitleColor,
            ),
      ],
    );
  }

  Widget _buildPublishedJobCard(
    PublicJobData job,
    Color primaryBlue,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final isAccepted = job.trabajoAceptado == 1;
    final isCompleted = job.trabajoAceptado == 2;
    final isConfirmed = job.trabajoAceptado == 3;
    final theme = Theme.of(context);
    final highlightColor = isAccepted
        ? theme.colorScheme.tertiaryContainer
        : isCompleted
        ? ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: theme.brightness,
          ).primaryContainer
        : null;
    final hasJobLocation =
        job.latitude.isFinite &&
        job.longitude.isFinite &&
        job.latitude >= -90 &&
        job.latitude <= 90 &&
        job.longitude >= -180 &&
        job.longitude <= 180;

    final jobCard = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlightColor != null ? Colors.transparent : cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined, size: 20, color: primaryBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job.serviceType,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ofrecimiento: \$${job.payment} MXN',
            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Descripción',
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  job.description,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              job.photoBytes,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          if (highlightColor != null)
            _AcceptedJobBlinkCard(
              baseColor: cardColor,
              blinkColor: highlightColor,
              onTap: () => _openAcceptedJobStatus(job),
              child: jobCard,
            )
          else if (isConfirmed)
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openAcceptedJobStatus(job),
                child: jobCard,
              ),
            )
          else
            jobCard,
          if (hasJobLocation) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(job.latitude, job.longitude),
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.tuempresa.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(job.latitude, job.longitude),
                          width: 48,
                          height: 48,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 2. Vista para Editar Perfil del Contratante
  Widget _buildEditProfileView(
    Color primaryBlue,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: primaryBlue.withValues(alpha: 0.14),
                      child: Icon(
                        Icons.person_rounded,
                        size: 56,
                        color: primaryBlue,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: cardColor, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _nombrePerfilController.text.trim().isEmpty
                    ? 'Contratante'
                    : _nombrePerfilController.text.trim(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Actualiza tus datos de contacto y cuenta',
                style: TextStyle(fontSize: 13, color: subtitleColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Información Personal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nombrePerfilController,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: 'Nombre completo',
            labelStyle: TextStyle(color: subtitleColor),
            prefixIcon: Icon(Icons.person_outline, color: primaryBlue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryBlue.withValues(alpha: 0.25)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryBlue, width: 2),
            ),
            filled: true,
            fillColor: cardColor,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _correoPerfilController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            labelStyle: TextStyle(color: subtitleColor),
            prefixIcon: Icon(Icons.email_outlined, color: primaryBlue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryBlue.withValues(alpha: 0.25)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryBlue, width: 2),
            ),
            filled: true,
            fillColor: cardColor,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _telefonoPerfilController,
          keyboardType: TextInputType.phone,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: 'Teléfono de contacto',
            labelStyle: TextStyle(color: subtitleColor),
            prefixIcon: Icon(Icons.phone_outlined, color: primaryBlue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryBlue.withValues(alpha: 0.25)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryBlue, width: 2),
            ),
            filled: true,
            fillColor: cardColor,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            setState(() => _currentSection = 'inicio');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Perfil actualizado correctamente!'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const Text(
            'Guardar Cambios',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // 3. Vista de Pagos al trabajador
  Widget _buildPaymentsView(
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    return ListView(
      children: [
        Text(
          'Historial y liberación de pagos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildPaymentTile(
          'Instalación de red',
          '\$450.00 MXN',
          'Liberado',
          cardColor,
          textColor,
        ),
        _buildPaymentTile(
          'Soporte de impresora',
          '\$250.00 MXN',
          'Pendiente de liberación',
          cardColor,
          textColor,
        ),
      ],
    );
  }

  // 4. Vista Interactiva de Calificación de Servicios
  Widget _buildRatingsView(
    Color primaryBlue,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final selectedWorker = _workersToRate[_selectedWorkerIndex];
    final average = selectedWorker.average;

    return ListView(
      children: [
        Text(
          'Selecciona un trabajador para evaluar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Toca las estrellas en cada criterio para generar su calificación',
          style: TextStyle(fontSize: 13, color: subtitleColor),
        ),
        const SizedBox(height: 14),

        // Selector de trabajadores
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_workersToRate.length, (index) {
              final worker = _workersToRate[index];
              final isSelected = index == _selectedWorkerIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  selected: isSelected,
                  selectedColor: primaryBlue,
                  backgroundColor: cardColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? primaryBlue
                        : primaryBlue.withValues(alpha: 0.25),
                  ),
                  avatar: Icon(
                    Icons.person_rounded,
                    size: 18,
                    color: isSelected ? Colors.white : primaryBlue,
                  ),
                  label: Text(worker.name),
                  onSelected: (_) {
                    setState(() {
                      _selectedWorkerIndex = index;
                    });
                  },
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 18),

        // Tarjeta resumen del trabajador seleccionado y promedio actual
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: primaryBlue.withValues(alpha: 0.14),
                child: Text(
                  selectedWorker.name[0],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedWorker.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      selectedWorker.service,
                      style: TextStyle(fontSize: 13, color: subtitleColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      average > 0 ? average.toStringAsFixed(1) : '0.0',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Criterios evaluables con estrellas seleccionables
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: primaryBlue.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              _buildInteractiveStarRow(
                label: 'Puntualidad',
                icon: Icons.schedule_rounded,
                currentRating: selectedWorker.puntualidad,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onRatingSelected: (val) {
                  setState(() => selectedWorker.puntualidad = val);
                },
              ),
              const Divider(height: 24),
              _buildInteractiveStarRow(
                label: 'Calidad',
                icon: Icons.verified_rounded,
                currentRating: selectedWorker.calidad,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onRatingSelected: (val) {
                  setState(() => selectedWorker.calidad = val);
                },
              ),
              const Divider(height: 24),
              _buildInteractiveStarRow(
                label: 'Atención',
                icon: Icons.support_agent_rounded,
                currentRating: selectedWorker.atencion,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onRatingSelected: (val) {
                  setState(() => selectedWorker.atencion = val);
                },
              ),
              const Divider(height: 24),
              _buildInteractiveStarRow(
                label: 'Tiempo de entrega',
                icon: Icons.timer_rounded,
                currentRating: selectedWorker.tiempoEntrega,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onRatingSelected: (val) {
                  setState(() => selectedWorker.tiempoEntrega = val);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Comentario opcional
        TextField(
          controller: _comentarioCalificacionController,
          maxLines: 2,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: 'Comentario adicional (opcional)',
            labelStyle: TextStyle(color: subtitleColor),
            prefixIcon: Icon(Icons.comment_outlined, color: primaryBlue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryBlue.withValues(alpha: 0.25)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryBlue, width: 2),
            ),
            filled: true,
            fillColor: cardColor,
          ),
        ),

        const SizedBox(height: 22),

        // Botón para enviar calificación y disparar notificación push real
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.send_rounded),
          label: const Text(
            'Enviar Calificación',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            if (selectedWorker.puntualidad == 0 ||
                selectedWorker.calidad == 0 ||
                selectedWorker.atencion == 0 ||
                selectedWorker.tiempoEntrega == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Por favor evalúa los 4 criterios con al menos 1 estrella.',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            final finalScore = selectedWorker.average.toStringAsFixed(1);
            _comentarioCalificacionController.clear();

            PushNotificationService.showNotification(
              title: 'Servicio calificado',
              body:
                  'Calificaste a ${selectedWorker.name} con $finalScore ★ en ${selectedWorker.service}.',
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '¡Servicio de ${selectedWorker.name} calificado ($finalScore ★)!',
                ),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInteractiveStarRow({
    required String label,
    required IconData icon,
    required int currentRating,
    required Color textColor,
    required Color subtitleColor,
    required ValueChanged<int> onRatingSelected,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: subtitleColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starValue = index + 1;
            final isFilled = starValue <= currentRating;
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onRatingSelected(starValue),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 28,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Widgets auxiliares de diseño
  Widget _buildPaymentTile(
    String concept,
    String amount,
    String status,
    Color cardColor,
    Color textColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                concept,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Text(
            status,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkerRatingItem {
  _WorkerRatingItem({
    required this.id,
    required this.name,
    required this.service,
    required this.puntualidad,
    required this.calidad,
    required this.atencion,
    required this.tiempoEntrega,
  });

  final String id;
  final String name;
  final String service;
  int puntualidad;
  int calidad;
  int atencion;
  int tiempoEntrega;

  double get average {
    final values = [puntualidad, calidad, atencion, tiempoEntrega];
    final ratedCount = values.where((v) => v > 0).length;
    if (ratedCount == 0) return 0;
    final sum = values.reduce((a, b) => a + b);
    return sum / 4.0;
  }
}

class _AcceptedJobBlinkCard extends StatefulWidget {
  const _AcceptedJobBlinkCard({
    required this.baseColor,
    required this.blinkColor,
    required this.onTap,
    required this.child,
  });

  final Color baseColor;
  final Color blinkColor;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_AcceptedJobBlinkCard> createState() => _AcceptedJobBlinkCardState();
}

class _AcceptedJobBlinkCardState extends State<_AcceptedJobBlinkCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          child: widget.child,
        ),
      ),
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          color: Color.lerp(
            widget.baseColor,
            widget.blinkColor,
            _controller.value,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}