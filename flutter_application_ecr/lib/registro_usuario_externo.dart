import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'perfil_usuario_externo.dart';
import 'services/activity_service.dart';
import 'services/api_service.dart';
import 'services/session_service.dart';
import 'widgets/custom_widgets.dart';

class RegistroUsuarioExterno extends StatefulWidget {
  const RegistroUsuarioExterno({super.key});

  @override
  State<RegistroUsuarioExterno> createState() => _RegistroUsuarioExternoState();
}

class _RegistroUsuarioExternoState extends State<RegistroUsuarioExterno> {
  final _formKey = GlobalKey<FormState>();
  
  // Datos del usuario
  String nombreCompleto = '';
  String tipoDocumento = '';
  String numeroDocumento = '';
  DateTime? fechaNacimiento;
  String? fechaError;
  bool _isSubmitting = false;
  String telefono = '';
  String direccion = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  
  bool _documentoAutoAsignado = false;

  // Datos del adulto responsable (si es menor de 14 años)
  bool esMenor14 = false;
  String nombreResponsable = '';
  String telefonoResponsable = '';
  String parentesco = '';
  
  final List<String> tiposDocumento = [
    'Cédula de Ciudadanía', 'Tarjeta de Identidad', 'Cédula de Extranjería', 'Pasaporte', 'Registro Civil'
  ];
  
  final List<String> parentescos = [
    'Padre', 'Madre', 'Tutor legal', 'Abuelo/a', 'Hermano/a mayor', 'Otro'
  ];

  DateTime get _fechaMinimaValida {
    final now = DateTime.now();
    return DateTime(now.year - 8, now.month, now.day);
  }

  int _calcularEdad(DateTime fecha) {
    final hoy = DateTime.now();
    var edad = hoy.year - fecha.year;
    if (hoy.month < fecha.month || (hoy.month == fecha.month && hoy.day < fecha.day)) {
      edad -= 1;
    }
    return edad;
  }

  void _actualizarEdad(DateTime fecha) {
    final age = _calcularEdad(fecha);
    setState(() {
      esMenor14 = age < 14;
      if (age < 18) {
        tipoDocumento = 'Tarjeta de Identidad';
        _documentoAutoAsignado = true;
      } else {
        _documentoAutoAsignado = false;
      }
    });
  }

  Future<void> _guardarPerfil() async {
    final payload = {
      'nombre_completo': nombreCompleto,
      'tipo_documento': tipoDocumento,
      'numero_documento': numeroDocumento,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String().split('T').first,
      'telefono': telefono,
      'direccion': direccion,
      'email': email,
      'password': password,
      'es_menor_14': esMenor14,
      if (esMenor14) 'acudiente': {
        'nombre': nombreResponsable,
        'telefono': telefonoResponsable,
        'parentesco': parentesco,
      },
    };

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await ApiService.registerUsuario(payload);
      final perfilData = {
        'nombre': response['nombre_completo'],
        'tipoDocumento': response['tipo_documento'],
        'numeroDocumento': response['numero_documento'],
        'fechaNacimiento': response['fecha_nacimiento'],
        'telefono': response['telefono'],
        'direccion': response['direccion'],
        'email': response['email'],
        'password': password,
        'esMenor14': response['es_menor_14'] ?? false,
        if (response['acudiente'] != null) 'nombreResponsable': response['acudiente']['nombre'],
        if (response['acudiente'] != null) 'telefonoResponsable': response['acudiente']['telefono'],
        if (response['acudiente'] != null) 'parentesco': response['acudiente']['parentesco'],
      };

      await SessionService.saveSession(
        token: response['auth_token'] ?? '',
        userId: response['id'].toString(),
        nombre: response['nombre_completo'] ?? '',
        email: response['email'] ?? '',
        rol: 'externo',
        tipoDocumento: response['tipo_documento'] ?? '',
        numeroDocumento: response['numero_documento'] ?? '',
        fechaNacimiento: response['fecha_nacimiento'] ?? '',
        direccion: response['direccion'] ?? '',
        telefono: response['telefono'] ?? '',
        esMenor14: response['es_menor_14'] ?? false,
        refreshToken: response['refresh_token'] ?? '',
        tokenExpiresAt: response['auth_token_expires_at'] ?? '',
      );
      ActivityService.instance.start();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PerfilUsuarioExterno(perfilData: perfilData),
        ),
      );
    } on ApiException catch (error) {
      _showErrorDialog(error.message);
    } catch (error) {
      _showErrorDialog('Error en el registro. Intenta de nuevo.');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Usuario Externo', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF00A99D),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(Icons.person_add, size: 80, color: Color(0xFF00A99D)),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Crear Cuenta',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Registra tus datos para acceder a los servicios',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),
              
              // Datos personales
              if (esMenor14)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A99D).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00A99D).withOpacity(0.4)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.child_care, color: Color(0xFF00A99D)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Complete los datos del MENOR, no del acudiente. Los datos del acudiente se registran más abajo.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF00A99D)),
                      ),
                    ),
                  ]),
                ),
              _buildSectionTitle(esMenor14 ? 'Datos del Menor' : 'Datos Personales'),
              const SizedBox(height: 10),
              _buildTextField(
                esMenor14 ? 'Nombre Completo del Menor' : 'Nombre Completo',
                Icons.person,
                (v) => nombreCompleto = v,
                validator: validateRequired,
              ),
              const SizedBox(height: 15),
              _buildDropdown(
                'Tipo de Documento',
                tiposDocumento,
                (v) => setState(() { tipoDocumento = v!; _documentoAutoAsignado = false; }),
                value: tipoDocumento.isEmpty ? null : tipoDocumento,
              ),
              if (_documentoAutoAsignado)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, size: 16, color: Color(0xFF00A99D)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Asignamos "Tarjeta de Identidad" por tu edad. Verifica que sea el correcto.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF00A99D)),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 15),
              _buildTextField(
                'Número de Documento',
                Icons.numbers,
                (v) => numeroDocumento = v,
                keyboardType: TextInputType.number,
                validator: validateNumber,
              ),
              const SizedBox(height: 15),
              _buildFechaNacimiento(),
              if (fechaError != null) ...[
                const SizedBox(height: 8),
                Text(fechaError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
              const SizedBox(height: 15),
              _buildTextField(
                'Teléfono',
                Icons.phone,
                (v) => telefono = v,
                keyboardType: TextInputType.phone,
                validator: validatePhone,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                'Dirección',
                Icons.location_on,
                (v) => direccion = v,
                validator: validateRequired,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                'Correo Electrónico',
                Icons.email,
                (v) => email = v,
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              
              const SizedBox(height: 20),
              _buildSectionTitle('Seguridad'),
              const SizedBox(height: 10),
              _buildTextField(
                'Contraseña',
                Icons.lock,
                (v) => password = v,
                obscureText: true,
                validator: (value) => validateMinLength(value, 6),
              ),
              const SizedBox(height: 15),
              _buildTextField(
                'Confirmar Contraseña',
                Icons.lock_outline,
                (v) => confirmPassword = v,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (value != password) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
              
              // Datos del adulto responsable (si aplica)
              if (esMenor14) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.orange.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange),
                          const SizedBox(width: 8),
                          const Text(
                            'Menor de 14 años',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Por ser menor de 14 años, necesitamos los datos de tu acudiente responsable:',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 15),
                      _buildSectionTitle('Datos del Acudiente'),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Nombre completo del acudiente',
                        Icons.person,
                        (v) => nombreResponsable = v,
                        validator: validateRequired,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        'Teléfono del acudiente',
                        Icons.phone,
                        (v) => telefonoResponsable = v,
                        keyboardType: TextInputType.phone,
                        validator: validatePhone,
                      ),
                      const SizedBox(height: 15),
                      _buildDropdown('Parentesco', parentescos, (v) => parentesco = v!),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          if (fechaNacimiento == null) {
                            setState(() {
                              fechaError = 'Por favor seleccione una fecha de nacimiento válida';
                            });
                            return;
                          }
                          if (fechaNacimiento!.isAfter(_fechaMinimaValida)) {
                            setState(() {
                              fechaError = 'Debes tener al menos 8 años para registrarte';
                            });
                            return;
                          }
                          if (password.length < 6) {
                            _showErrorDialog('La contraseña debe tener al menos 6 caracteres');
                            return;
                          }
                          if (esMenor14) {
                            if (nombreResponsable.isEmpty || telefonoResponsable.isEmpty || parentesco.isEmpty) {
                              _showErrorDialog('Por favor complete los datos del acudiente');
                              return;
                            }
                          }
                          await _guardarPerfil();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A99D),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('REGISTRARSE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
    );
  }

  Widget _buildTextField(String label, IconData icon, Function(String) onChanged, 
      {TextInputType keyboardType = TextInputType.text, bool obscureText = false, String? Function(String?)? validator}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00A99D)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: keyboardType == TextInputType.number ? [FilteringTextInputFormatter.digitsOnly] : null,
      onChanged: onChanged,
      validator: validator ?? (value) => value!.isEmpty ? 'Campo requerido' : null,
    );
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged, {String? value}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.arrow_drop_down_circle, color: Color(0xFF00A99D)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Colors.white,
      ),
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Seleccione una opción' : null,
    );
  }

  Widget _buildFechaNacimiento() {
    return InkWell(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _fechaMinimaValida,
          firstDate: DateTime(1900),
          lastDate: _fechaMinimaValida,
        );
        if (picked != null) {
          setState(() {
            fechaNacimiento = picked;
            fechaError = null;
            _actualizarEdad(picked);
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha de Nacimiento',
          prefixIcon: Icon(Icons.cake, color: Color(0xFF00A99D)),
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          fechaNacimiento == null 
            ? 'Seleccione una fecha' 
            : '${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}',
          style: TextStyle(color: fechaNacimiento == null ? Colors.grey : Colors.black),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [Icon(Icons.error, color: Colors.red), SizedBox(width: 8), Text('Error')],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A99D)),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}