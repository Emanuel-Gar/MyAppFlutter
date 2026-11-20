import 'package:flutter/material.dart';

import '../services/publicjob_service.dart';
import 'chat_screen.dart';

class AcceptedJobScreen extends StatefulWidget {
  const AcceptedJobScreen({
    super.key,
    required this.job,
    required this.statusIndex,
    required this.onStatusChanged,
    required this.onCancel,
  });

  final PublicJobData job;
  final int statusIndex;
  final ValueChanged<int> onStatusChanged;
  final VoidCallback onCancel;

  @override
  State<AcceptedJobScreen> createState() => _AcceptedJobScreenState();
}

class _AcceptedJobScreenState extends State<AcceptedJobScreen> {
  late int _statusIndex;

  @override
  void initState() {
    super.initState();
    _statusIndex = widget.statusIndex;
    widget.job.estadoTrabajo = _statusIndex;
    if (_statusIndex == 2) {
      widget.job.trabajoAceptado = 2;
    } else if (widget.job.trabajoAceptado == 0) {
      widget.job.trabajoAceptado = 1;
    }
  }

  static const _statuses = [
    (title: 'Trabajo aceptado y en camino', icon: Icons.directions_car_rounded),
    (title: 'Realizando el trabajo', icon: Icons.handyman_rounded),
    (title: 'Trabajo finalizado', icon: Icons.task_alt_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguimiento del trabajo')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.job.serviceType,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          recipientName: 'Contratante',
                          taskTitle: widget.job.serviceType,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Contactar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.job.description),
            const SizedBox(height: 8),
            Text(
              'Pago ofrecido: \$${widget.job.payment} MXN',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 28),
            Text(
              'Estatus del trabajo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < _statuses.length; index++)
              Card(
                color: index <= _statusIndex
                    ? Colors.green.withValues(alpha: 0.1)
                    : null,
                child: ListTile(
                  leading: Icon(
                    index < _statusIndex
                        ? Icons.check_circle
                        : _statuses[index].icon,
                    color: index <= _statusIndex ? Colors.green : Colors.grey,
                    size: 30,
                  ),
                  title: Text(
                    _statuses[index].title,
                    style: TextStyle(
                      fontWeight: index == _statusIndex
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: index == _statusIndex
                          ? Colors.green.shade800
                          : null,
                    ),
                  ),
                  subtitle: index == _statusIndex
                      ? const Text('Estatus actual')
                      : null,
                  trailing: index == _statusIndex
                      ? const Icon(
                          Icons.radio_button_checked,
                          color: Colors.green,
                        )
                      : null,
                  onTap: widget.job.trabajoAceptado >= 2
                      ? null
                      : () {
                          setState(() {
                            _statusIndex = index;
                            widget.job.estadoTrabajo = index;
                            widget.job.trabajoAceptado = index == 2 ? 2 : 1;
                          });
                          widget.onStatusChanged(index);
                        },
                ),
              ),
            const SizedBox(height: 24),
            if (_statusIndex == 2)
              Card(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: const ListTile(
                  leading: Icon(Icons.hourglass_top_rounded),
                  title: Text(
                    'Espere a que el contratante confirme el trabajo y realice el pago.',
                  ),
                ),
              ),
            if (_statusIndex == 2) const SizedBox(height: 16),
            if (_statusIndex < 2)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.red.shade700),
                ),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancelar trabajo'),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onCancel();
                },
              ),
          ],
        ),
      ),
    );
  }
}
