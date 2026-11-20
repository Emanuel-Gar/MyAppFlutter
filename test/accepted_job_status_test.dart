import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teayudoapp/screens/accepted_job_screen.dart';
import 'package:teayudoapp/screens/accpted_job_contratante_screen.dart';
import 'package:teayudoapp/services/publicjob_service.dart';

PublicJobData _createJob({int accepted = 1, int status = 0}) {
  return PublicJobData(
    serviceType: 'Plomería',
    description: 'Reparar una fuga',
    payment: '350',
    estimatedDuration: '2 horas',
    latitude: 19.3,
    longitude: -98.2,
    photoBytes: Uint8List(0),
    photoName: 'trabajo.jpg',
    trabajoAceptado: accepted,
    estadoTrabajo: status,
  );
}

void main() {
  testWidgets('marking a job complete sets both statuses to 2', (tester) async {
    final job = _createJob();

    await tester.pumpWidget(
      MaterialApp(
        home: AcceptedJobScreen(
          job: job,
          statusIndex: 0,
          onStatusChanged: (_) {},
          onCancel: () {},
        ),
      ),
    );

    await tester.tap(find.text('Trabajo finalizado'));
    await tester.pump();

    expect(job.trabajoAceptado, 2);
    expect(job.estadoTrabajo, 2);
  });

  testWidgets(
    'contractor confirmation sets status 3 and selects Mercado Pago',
    (tester) async {
      final job = _createJob(accepted: 2, status: 2);
      publicJobs
        ..clear()
        ..add(job);

      await tester.pumpWidget(
        MaterialApp(home: AcceptedJobContratanteScreen(job: job)),
      );

      final confirmButton = find.text('Confirma el trabajo finalizado');
      await tester.ensureVisible(confirmButton);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(job.trabajoAceptado, 3);
      expect(find.text('Confirmar pago'), findsOneWidget);
      expect(find.text('Mercado Pago'), findsOneWidget);
      expect(find.text('\$35.00 MXN'), findsOneWidget);
      expect(find.text('\$385.00 MXN'), findsOneWidget);

      final confirmPayment = find.text('Confirmar pago simulado');
      await tester.ensureVisible(confirmPayment);
      await tester.tap(confirmPayment);
      await tester.pumpAndSettle();

      expect(job.paymentMethod, 'Mercado Pago');
      expect(job.paymentConfirmed, isTrue);
      expect(publicJobs, isNot(contains(job)));
    },
  );
}
