import 'package:flutter/material.dart';
import '../models/job_task.dart';
import 'chat_screen.dart';

class JobDetailScreen extends StatelessWidget {
  final JobTask task;

  const JobDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.category),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título principal
            Text(
              task.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Distancia y tipo
            Row(
              children: [
                Chip(
                  label: Text(task.type == TaskType.oficio ? "Oficio profesional" : "Ayuda rápida / Tarea simple"),
                  backgroundColor: task.type == TaskType.oficio ? Colors.blue.shade50 : Colors.orange.shade50,
                  labelStyle: TextStyle(
                    color: task.type == TaskType.oficio ? Colors.blue.shade800 : Colors.orange.shade800,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                Text(" A ${task.distance} de ti", style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const Divider(height: 30),

            // En qué consiste (Descripción)
            const Text("Descripción de la tarea", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(task.description, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4)),
            const SizedBox(height: 20),

            // Horario / Duración estimada
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.blue),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Horario / Duración estimada", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(task.schedule, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Pago ofrecido
            Row(
              children: [
                const Icon(Icons.payments, color: Color(0xFF2E7D32)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pago ofrecido", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      "\$${task.payment.toStringAsFixed(2)} MXN",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),

            // Botón de aceptación / contratación dentro de la app (Verde institucional)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // AQUÍ ES EXACTAMENTE DONDE LO VAS A PONER:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        recipientName: "María López (Solicitante)",
                        taskTitle: task.title,
                      ),
                    ),
                  );
                },
                child: const Text("Aceptar trabajo y contactar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}