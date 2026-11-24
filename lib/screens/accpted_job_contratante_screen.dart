import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/publicjob_service.dart';
import '../services/push_notification_service.dart';

class AcceptedJobContratanteScreen extends StatefulWidget {
  const AcceptedJobContratanteScreen({super.key, required this.job});

  final PublicJobData job;

  @override
  State<AcceptedJobContratanteScreen> createState() =>
      _AcceptedJobContratanteScreenState();
}

class _AcceptedJobContratanteScreenState
    extends State<AcceptedJobContratanteScreen> {
  static const _statuses = [
    (title: 'Trabajo aceptado y en camino', icon: Icons.directions_car_rounded),
    (title: 'Realizando el trabajo', icon: Icons.handyman_rounded),
    (title: 'Trabajo finalizado', icon: Icons.task_alt_rounded),
  ];

  Future<void> _confirmWorkCompleted() async {
    final serviceAmount = double.tryParse(widget.job.payment);
    if (serviceAmount == null ||
        !serviceAmount.isFinite ||
        serviceAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El monto del trabajo no es válido.')),
      );
      return;
    }

    final appCommission = serviceAmount * appCommissionRate;
    final totalAmount = serviceAmount + appCommission;
    setState(() => widget.job.trabajoAceptado = 3);
    var paymentConfirmed = false;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) => PopScope(
          canPop: paymentConfirmed,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirmar pago',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selecciona Mercado Pago para confirmar el pago. '
                      'Esta simulación no realizará ningún cobro real.',
                    ),
                    const Divider(height: 24),
                    _PaymentAmountRow(
                      label: 'Total a pagar',
                      amount: totalAmount,
                      isTotal: true,
                    ),
                    const SizedBox(height: 12),
                    const Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.account_balance_wallet_outlined),
                        ),
                        title: Text('Mercado Pago'),
                        subtitle: Text('Método de pago seleccionado'),
                        trailing: Icon(Icons.check_circle, color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          widget.job
                            ..paymentMethod = 'Mercado Pago'
                            ..paymentConfirmed = true
                            ..trabajoAceptado = 3;
                          publicJobs.remove(widget.job);
                          setState(() {});
                          setModalState(() => paymentConfirmed = true);
                          try {
                            await PushNotificationService.showPaymentNotifications(
                              serviceType: widget.job.serviceType,
                              workerAmount: serviceAmount,
                              totalAmount: totalAmount,
                            );
                          } on PlatformException catch (error) {
                            debugPrint(
                              'Error mostrando notificaciones de pago: $error',
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'El pago se confirmó, pero no se pudieron mostrar las notificaciones.',
                                  ),
                                ),
                              );
                            }
                          } on MissingPluginException catch (error) {
                            debugPrint(
                              'Plugin de notificaciones no disponible: $error',
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'El pago se confirmó, pero las notificaciones no están disponibles en este dispositivo.',
                                  ),
                                ),
                              );
                            }
                          }
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (modalContext.mounted) {
                              Navigator.of(modalContext).pop(true);
                            }
                          });
                        },
                        icon: const Icon(Icons.lock_open_rounded),
                        label: const Text('Confirmar pago simulado'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final statusIndex = job.estadoTrabajo.clamp(0, _statuses.length - 1);

    return Scaffold(
      appBar: AppBar(title: const Text('Estatus del trabajo')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              job.serviceType,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(job.description),
            const SizedBox(height: 8),
            Text(
              'Duración estimada: ${job.estimatedDuration}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text('Pago ofrecido: \$${job.payment} MXN'),
            const SizedBox(height: 28),
            Text(
              'Seguimiento del trabajo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < _statuses.length; index++)
              Card(
                color: index <= statusIndex
                    ? Colors.green.withValues(alpha: 0.1)
                    : null,
                child: ListTile(
                  leading: Icon(
                    index < statusIndex
                        ? Icons.check_circle
                        : _statuses[index].icon,
                    color: index <= statusIndex ? Colors.green : Colors.grey,
                    size: 30,
                  ),
                  title: Text(
                    _statuses[index].title,
                    style: TextStyle(
                      fontWeight: index == statusIndex
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: index == statusIndex
                          ? Colors.green.shade800
                          : null,
                    ),
                  ),
                  subtitle: index == statusIndex
                      ? const Text('Estatus actual')
                      : null,
                  trailing: index == statusIndex
                      ? const Icon(
                          Icons.radio_button_checked,
                          color: Colors.green,
                        )
                      : null,
                ),
              ),
            if (job.trabajoAceptado == 2 ||
                (job.trabajoAceptado == 3 && !job.paymentConfirmed)) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _confirmWorkCompleted,
                  icon: const Icon(Icons.task_alt),
                  label: Text(
                    job.trabajoAceptado == 2
                        ? 'Confirma el trabajo finalizado'
                        : 'Continuar con el pago',
                  ),
                ),
              ),
            ] else if (job.trabajoAceptado == 3 && job.paymentConfirmed) ...[
              const SizedBox(height: 20),
              Card(
                color: Colors.green.withValues(alpha: 0.1),
                child: ListTile(
                  leading: const Icon(Icons.verified, color: Colors.green),
                  title: const Text('Trabajo finalizado confirmado'),
                  subtitle: Text(
                    job.paymentMethod == null
                        ? 'Método de pago pendiente de seleccionar'
                        : 'Método seleccionado: ${job.paymentMethod}',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentAmountRow extends StatelessWidget {
  const _PaymentAmountRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  final String label;
  final double amount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = isTotal
        ? Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: style)),
        Text('\$${amount.toStringAsFixed(2)} MXN', style: style),
      ],
    );
  }
}
