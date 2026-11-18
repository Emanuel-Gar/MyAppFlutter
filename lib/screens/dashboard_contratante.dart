import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/publicjob_service.dart';
import 'public_job_screen.dart';
import '../widgets/te_ayudo_app_bar.dart';
import '../services/push_notification_service.dart';

class ContratanteScreen extends StatefulWidget {
  const ContratanteScreen({super.key});

  @override
  State<ContratanteScreen> createState() => _ContratanteScreenState();
}

class _ContratanteScreenState extends State<ContratanteScreen> {
  // Controla qué sección se muestra en el cuerpo principal
  String _currentSection = 'inicio';

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

    final appBarColor = isDarkMode ? const Color(0xFF1E1E1E) : primaryBlue;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          _getSectionTitle(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: appBarColor,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: ThemeToggleButton(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: const Text(
                'CC', // Contratante Cliente
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      // --- MENÚ DE HAMBURGUESA (DRAWER) ---
      drawer: Drawer(
        backgroundColor: cardColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: primaryBlue),
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
                  const Text(
                    'Panel de Contratante',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'contratante@teayudo.com',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_rounded, color: primaryBlue),
              title: Text('Panel Principal', style: TextStyle(color: textColor)),
              onTap: () {
                setState(() => _currentSection = 'inicio');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline_rounded, color: primaryBlue),
              title: Text('Publicar un trabajo', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                _openPublicJobScreen();
              },
            ),
            ListTile(
              leading: const Icon(Icons.payments_rounded, color: primaryBlue),
              title: Text('Pago al trabajador', style: TextStyle(color: textColor)),
              onTap: () {
                setState(() => _currentSection = 'pagos');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_rate_rounded, color: primaryBlue),
              title: Text('Calificación de servicios', style: TextStyle(color: textColor)),
              onTap: () {
                setState(() => _currentSection = 'calificaciones');
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
      default:
        return 'Mis Trabajos Contratados';
    }
  }

  // Elemento secundario del acordeón de notificaciones conectado al helper real
  Widget _buildNotificationSubItem(String title, String subtitle, BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: const Icon(Icons.notifications_active_rounded, size: 18, color: Colors.blue),
      onTap: () {
        Navigator.pop(context); // Cierra el drawer

        // Llamada a la función helper externa para enviar la notificación real del sistema
        PushNotificationService.showNotification(
          title: title,
          body: subtitle,
        );
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
      return _buildRatingsView(cardColor, textColor, subtitleColor);
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
    final hasJobLocation =
        job.latitude.isFinite &&
        job.longitude.isFinite &&
        job.latitude >= -90 &&
        job.latitude <= 90 &&
        job.longitude >= -180 &&
        job.longitude <= 180;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
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
                    Icon(
                      Icons.assignment_outlined,
                      size: 20,
                      color: primaryBlue,
                    ),
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
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
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
          ),
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

  // 4. Vista de Calificación de servicios
  Widget _buildRatingsView(
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    return ListView(
      children: [
        Text(
          'Califica la calidad del servicio brindado',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildRatingTile(
          'Carlos Mendoza',
          'Red doméstica',
          5,
          cardColor,
          textColor,
          subtitleColor,
        ),
        _buildRatingTile(
          'Jorge Luis',
          'Tubería de agua',
          4,
          cardColor,
          textColor,
          subtitleColor,
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

  Widget _buildRatingTile(
    String worker,
    String service,
    int stars,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
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
                worker,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Servicio: $service',
                style: TextStyle(fontSize: 12, color: subtitleColor),
              ),
            ],
          ),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < stars ? Icons.star_rounded : Icons.star_border_rounded,
                color: Colors.amber,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
