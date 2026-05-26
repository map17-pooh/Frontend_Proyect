import 'package:flutter/material.dart';
import 'perfil_usuario_externo.dart';
import 'recuperar_password.dart';
import 'registro_usuario_externo.dart';
import 'services/activity_service.dart';
import 'services/api_service.dart';
import 'services/session_service.dart';

class LoginUsuarioExterno extends StatefulWidget {
  const LoginUsuarioExterno({super.key});

  @override
  State<LoginUsuarioExterno> createState() => _LoginUsuarioExternoState();
}

class _LoginUsuarioExternoState extends State<LoginUsuarioExterno> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.loginUsuario(email, password);
      final perfilData = {
        'nombre': response['nombre_completo'],
        'tipoDocumento': response['tipo_documento'],
        'numeroDocumento': response['numero_documento'],
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
      _showErrorDialog('Error en el inicio de sesión. Intenta de nuevo.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToRegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistroUsuarioExterno()),
    );
  }

  void _navigateToRecuperar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecuperarPassword()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF00A99D),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Color(0xFF00A99D),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Bienvenido de nuevo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Inicia sesión para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Correo Electrónico',
                            prefixIcon: const Icon(Icons.email, color: Color(0xFF00A99D)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) => email = value,
                          validator: (value) {
                            if (value!.isEmpty) return 'Campo requerido';
                            if (!value.contains('@')) return 'Ingrese un email válido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock, color: Color(0xFF00A99D)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          obscureText: _obscurePassword,
                          onChanged: (value) => password = value,
                          validator: (value) {
                            if (value!.isEmpty) return 'Campo requerido';
                            if (value.length < 6) return 'Mínimo 6 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _iniciarSesion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A99D),
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'INICIAR SESIÓN',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('¿No tienes cuenta?'),
                            TextButton(
                              onPressed: _navigateToRegistro,
                              child: const Text(
                                'Regístrate aquí',
                                style: TextStyle(color: Color(0xFF00A99D), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _navigateToRecuperar,
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
