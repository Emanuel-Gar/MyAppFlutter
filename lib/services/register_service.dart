import 'dart:async';

class RegistroService {
  // 1. Crear la instancia interna y única de la clase
  static final RegistroService _instance = RegistroService._internal();

  // 2. Constructor privado para evitar que se creen copias con 'RegistroService()'
  RegistroService._internal();

  // 3. Al llamar a RegistroService(), Dart devolverá siempre la misma instancia única
  factory RegistroService() => _instance;

  // Tu lista en memoria
  final List<Map<String, dynamic>> _usuariosRegistrados = [];
  List<Map<String, dynamic>> get usuariosRegistrados => _usuariosRegistrados;

  Future<Map<String, dynamic>> registrarUsuario({
    required String ine,
    required String curp,
    required String rfc,
    required String fechaNacimiento,
    required String nombre,
    required String apellidoPaterno,
    String? apellidoMaterno,
    required String correoElectronico,
    required String contrasena,
    required String tipoUsuario,
  }) async {
    if (tipoUsuario != 'trabajador' && tipoUsuario != 'contratante') {
      return {'success': false, 'message': 'El tipo de usuario no es válido'};
    }

    final datos = <String, dynamic>{
      'ine': ine,
      'curp': curp,
      'rfc': rfc,
      'fechaNacimiento': fechaNacimiento,
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'correoElectronico': correoElectronico,
      'contrasena': contrasena,
      'tipoUsuario': tipoUsuario,
    };

    if (tipoUsuario == 'trabajador') {
      datos.addAll({
        'staruno': 0,
        'stardos': 0,
        'startres': 0,
        'starcuatro': 0,
        'starcinco': 0,
      });
    }

    await Future.delayed(const Duration(seconds: 2));

    // Guardamos en la lista única en memoria
    _usuariosRegistrados.add(datos);

    return {'success': true, 'message': 'Usuario registrado', 'json': datos};
  }
}
