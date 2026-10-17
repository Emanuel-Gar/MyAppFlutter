import 'package:flutter/material.dart';
import '../screens/login.dart'; // 1. Importa tu archivo de la pantalla

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Opcional: quita la etiqueta de "Debug"
      title: 'Mi Proyecto',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // 2. Declara tu LoginScreen como la pantalla inicial
    );
  }
}