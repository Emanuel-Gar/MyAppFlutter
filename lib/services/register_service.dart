import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class RegistroService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  Future<Map<String, dynamic>> registrarUsuario({
    required String ine,
    required String curp,
    required String rfc,
    required String fechaNacimiento,
    required String nombre,
    required String apellidoPaterno,
    String? apellidoMaterno,
    required String tipoUsuario,
  }) async {
    //final url = Uri.parse('$baseUrl/api/registro');

    final datos = {
      'ine': ine,
      'curp': curp,
      'rfc': rfc,
      'fechaNacimiento': fechaNacimiento,
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'tipoUsuario': tipoUsuario,
    };
    final String data = jsonEncode(datos);
    print(data);
    await Future.delayed(Duration(seconds: 2));

    return {'message': 'Usuario registrado'};
  }
}
