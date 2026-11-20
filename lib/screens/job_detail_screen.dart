import 'package:flutter/material.dart';

import '../services/publicjob_service.dart';
import '../widgets/te_ayudo_app_bar.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key, required this.job, required this.onAccept});

  final PublicJobData job;
  final VoidCallback onAccept;

  String _formatDateTime(DateTime value) {
    final date = value.toLocal();
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(job.serviceType),
        backgroundColor: isDarkMode ? const Color(0xFF12202E) : Colors.blue,
        foregroundColor: Colors.white,
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (job.photoBytes.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        job.photoBytes,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    job.serviceType,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _DetailRow(
                    icon: Icons.description_outlined,
                    label: 'Descripción',
                    value: job.description,
                  ),
                  _DetailRow(
                    icon: Icons.timer_outlined,
                    label: 'Duración estimada',
                    value: job.estimatedDuration,
                  ),
                  _DetailRow(
                    icon: Icons.calendar_month_outlined,
                    label: 'Fecha y hora de publicación',
                    value: _formatDateTime(job.registeredAt),
                  ),
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Ubicación del trabajo',
                    value:
                        '${job.latitude.toStringAsFixed(6)}, '
                        '${job.longitude.toStringAsFixed(6)}',
                  ),
                  _DetailRow(
                    icon: Icons.payments_outlined,
                    label: 'Pago ofrecido',
                    value: '\$${job.payment} MXN',
                    valueColor: const Color(0xFF2E7D32),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onAccept();
                  },
                  child: const Text(
                    'Aceptar trabajo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: valueColor ?? Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: valueColor,
                    fontWeight: valueColor == null
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
