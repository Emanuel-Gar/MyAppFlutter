import 'package:flutter/material.dart';

import 'dashboard.dart'; // 1. Importa la pantalla de tu compañero

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // Dirección del degradado (de arriba hacia abajo o en diagonal)
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 1, 75, 140), // Azul principal
              Color.fromARGB(255, 54, 165, 255), // Azul claro
              const Color.fromARGB(
                255,
                154,
                153,
                153,
              ), // Blanco (Color de apoyo)
            ],
            // Opcional: define las paradas (stops) para controlar dónde cambia cada color (de 0.0 a 1.0)
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Card(
            color: Color.fromARGB(255, 213, 214, 215),
            elevation: 10.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80),
            ),
            child: SizedBox(
              width: 500,
              height: 500,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Bienvenid@',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Inicia sesión para continuar',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 9, 81, 10), // Color de fondo (ej. Verde para botones importantes)
                        foregroundColor: const Color.fromARGB(
                          255,
                          251,
                          252,
                          252,
                        ), // Color del texto y de los iconos
                      ),
                      onPressed: () {
                        // 2. Aquí haces la navegación hacia el Dashboard
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                          ),
                        );
                      },
                      child: const Text('Entrar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
