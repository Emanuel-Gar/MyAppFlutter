import 'package:flutter/material.dart';

import '../widgets/te_ayudo_app_bar.dart';
import '../services/register_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _ineController = TextEditingController();
  final _curpController = TextEditingController();
  final _rfcController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final RegistroService _registroService = RegistroService();

  DateTime? _fechaNacimiento;

  String _tipoUsuario = 'trabajador';

  bool _registrando = false;

  @override
  void dispose() {
    _ineController.dispose();
    _curpController.dispose();
    _rfcController.dispose();
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();

    super.dispose();
  }

  // Selector de fecha de nacimiento.
  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();

    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime(hoy.year - 18, hoy.month, hoy.day),
      firstDate: DateTime(1900),
      lastDate: hoy,
      helpText: 'Selecciona tu fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (fecha != null) {
      setState(() {
        _fechaNacimiento = fecha;
      });
    }
  }

  // Validar campos obligatorios.
  String? _validarCampo(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El campo $campo es obligatorio';
    }

    return null;
  }

  // Validar formato de CURP.
  String? _validarCURP(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa tu CURP';
    }

    final curp = valor.trim().toUpperCase();

    final regex = RegExp(
      r'^[A-Z][AEIOUX][A-Z]{2}\d{2}'
      r'(0[1-9]|1[0-2])'
      r'(0[1-9]|[12]\d|3[01])'
      r'[HM]'
      r'(AS|BC|BS|CC|CL|CM|CS|CH|DF|DG|GT|GR|HG|JC|MC|MN|MS|'
      r'NT|NL|OC|PL|QT|QR|SP|SL|SR|TC|TS|TL|VZ|YN|ZS|NE)'
      r'[B-DF-HJ-NP-TV-Z]{3}'
      r'[A-Z0-9]\d$',
    );

    if (!regex.hasMatch(curp)) {
      return 'La CURP no tiene un formato válido';
    }

    return null;
  }

  // Validar formato de RFC.
  String? _validarRFC(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa tu RFC';
    }

    final rfc = valor.trim().toUpperCase();

    final regex = RegExp(
      r'^(?:[A-Z&Ñ]{3}\d{6}[A-Z0-9]{3}|'
      r'[A-Z&Ñ]{4}\d{6}[A-Z0-9]{3})$',
    );

    if (!regex.hasMatch(rfc)) {
      return 'El RFC debe tener 12 o 13 caracteres';
    }

    return null;
  }

  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona tu fecha de nacimiento')),
      );
      return;
    }

    if (_registrando) return;

    setState(() {
      _registrando = true;
    });

    try {
      final respuesta = await _registroService.registrarUsuario(
        ine: _ineController.text.trim(),
        curp: _curpController.text.trim().toUpperCase(),
        rfc: _rfcController.text.trim().toUpperCase(),
        fechaNacimiento:
            '${_fechaNacimiento!.year}-'
            '${_fechaNacimiento!.month.toString().padLeft(2, '0')}-'
            '${_fechaNacimiento!.day.toString().padLeft(2, '0')}',
        nombre: _nombreController.text.trim(),
        apellidoPaterno: _apellidoPaternoController.text.trim(),
        apellidoMaterno: _apellidoMaternoController.text.trim().isEmpty
            ? null
            : _apellidoMaternoController.text.trim(),
        tipoUsuario: _tipoUsuario,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            respuesta['message'] ??
                respuesta['mensaje'] ??
                'Registro realizado correctamente',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Aquí puedes navegar a otra pantalla si lo necesitas.
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo completar el registro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _registrando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const TeAyudoAppBar(),
      backgroundColor: colorScheme.surface,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),

              child: Card(
                elevation: 2,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(22),

                  child: Form(
                    key: _formKey,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,

                      children: [
                        const Icon(
                          Icons.person_add_alt_1,
                          size: 52,
                          color: Color(0xFF2457C5),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Crear cuenta',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Ingresa tus datos para registrarte en '
                          'Te Ayudo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 28),

                        _tituloSeccion('Identificación'),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _ineController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'INE',
                            hintText: 'Clave o folio de identificación',
                            prefixIcon: Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (valor) => _validarCampo(valor, 'INE'),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _curpController,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 18,
                          decoration: const InputDecoration(
                            labelText: 'CURP',
                            hintText: 'Ingresa tu CURP',
                            prefixIcon: Icon(Icons.fingerprint),
                            counterText: '',
                            border: OutlineInputBorder(),
                          ),
                          validator: _validarCURP,
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _rfcController,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 13,
                          decoration: const InputDecoration(
                            labelText: 'RFC',
                            hintText: 'Ingresa tu RFC',
                            prefixIcon: Icon(Icons.assignment_outlined),
                            counterText: '',
                            border: OutlineInputBorder(),
                          ),
                          validator: _validarRFC,
                        ),

                        const SizedBox(height: 28),

                        _tituloSeccion('Datos personales'),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _nombreController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nombre(s)',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (valor) => _validarCampo(valor, 'nombre'),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _apellidoPaternoController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Apellido paterno',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (valor) =>
                              _validarCampo(valor, 'apellido paterno'),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _apellidoMaternoController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Apellido materno (opcional)',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Fecha de nacimiento.
                        FormField<DateTime>(
                          validator: (_) {
                            if (_fechaNacimiento == null) {
                              return 'Selecciona tu fecha de nacimiento';
                            }

                            return null;
                          },

                          builder: (field) {
                            return InkWell(
                              onTap: () async {
                                await _seleccionarFecha();

                                field.didChange(_fechaNacimiento);
                              },

                              borderRadius: BorderRadius.circular(12),

                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Fecha de nacimiento',
                                  prefixIcon: const Icon(
                                    Icons.calendar_month_outlined,
                                  ),
                                  suffixIcon: const Icon(Icons.arrow_drop_down),
                                  border: const OutlineInputBorder(),
                                  errorText: field.errorText,
                                ),

                                child: Text(
                                  _fechaNacimiento == null
                                      ? 'Selecciona una fecha'
                                      : '${_fechaNacimiento!.day.toString().padLeft(2, '0')}/'
                                            '${_fechaNacimiento!.month.toString().padLeft(2, '0')}/'
                                            '${_fechaNacimiento!.year}',
                                  style: TextStyle(
                                    color: _fechaNacimiento == null
                                        ? colorScheme.onSurfaceVariant
                                        : colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        _tituloSeccion('Tipo de registro'),

                        const SizedBox(height: 8),

                        Text(
                          '¿Cómo deseas registrarte?',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: _opcionUsuario(
                                context: context,
                                titulo: 'Trabajador',
                                icono: Icons.engineering_outlined,
                                seleccionado: _tipoUsuario == 'trabajador',
                                onTap: () {
                                  setState(() {
                                    _tipoUsuario = 'trabajador';
                                  });
                                },
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: _opcionUsuario(
                                context: context,
                                titulo: 'Contratante',
                                icono: Icons.business_center_outlined,
                                seleccionado: _tipoUsuario == 'contratante',
                                onTap: () {
                                  setState(() {
                                    _tipoUsuario = 'contratante';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          height: 54,

                          child: FilledButton.icon(
                            onPressed: _registrando ? null : _registrar,
                            icon: _registrando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.check_circle_outline),
                            label: Text(
                              _registrando ? 'Registrando...' : 'Registrarme',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Verifica tus datos antes de continuar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tituloSeccion(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2457C5),
      ),
    );
  }

  Widget _opcionUsuario({
    required BuildContext context,
    required String titulo,
    required IconData icono,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),

        decoration: BoxDecoration(
          color: seleccionado
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerLow,

          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: seleccionado
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: seleccionado ? 2 : 1,
          ),
        ),

        child: Column(
          children: [
            Icon(
              icono,
              size: 30,
              color: seleccionado
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),

            const SizedBox(height: 8),

            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: seleccionado
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Icon(
              seleccionado
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: seleccionado
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
