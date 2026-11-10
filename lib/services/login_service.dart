import 'dart:async';

import './register_service.dart';

class LoginService {
  static final LoginService _instance = LoginService._internal();

  LoginService._internal();

  factory LoginService() => _instance;

  Map<String, dynamic>? _userLog;
  Map<String, dynamic>? get userLog =>
      _userLog == null ? null : Map<String, dynamic>.unmodifiable(_userLog!);

  Future<Map<String, dynamic>> loginUser({
    required String correoElectronico,
    required String contrasena,
  }) async {
    _userLog = null;

    final user = RegistroService();
    final usuarioEncontrado = user.usuariosRegistrados
        .where(
          (usuario) =>
              usuario['correoElectronico'] == correoElectronico &&
              usuario['contrasena'] == contrasena,
        )
        .firstOrNull;

    if (usuarioEncontrado != null) {
      _userLog = Map<String, dynamic>.from(usuarioEncontrado)
        ..remove('contrasena');
      print('Usuario logueado: $_userLog');
      return {'success': true, 'message': 'Login exitoso', 'tipoUsuario': _userLog!['tipoUsuario']};
    }

    return {
      'success': false,
      'message': 'Usuario no encontrado o datos incorrectos',
    };
  }
}
