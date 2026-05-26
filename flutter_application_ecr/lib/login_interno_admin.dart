import 'package:flutter/material.dart';
import 'registro_interno_admin.dart';
import 'perfil_interno_admin.dart';
import 'services/activity_service.dart';
import 'services/api_service.dart';
import 'services/session_service.dart';

class LoginInternoAdmin extends StatefulWidget {
  const LoginInternoAdmin({super.key});

  @override
  State<LoginInternoAdmin> createState() => _LoginInternoAdminState();
}

class _LoginInternoAdminState extends State<LoginInternoAdmin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.loginInterno(
        _emailController.text.trim(),
        _passwordController.text,
      );

      final rol = response['tipo'] as String? ?? 'Interno';
      final perfilData = {
        'nombre': response['nombre_completo'] ?? '',
        'email': response['email'] ?? '',
        'documento': response['puesto'] ?? response['nivel'] ?? '',
        'telefono': '',
        'rol': rol,
      };

      await SessionService.saveSession(
        token: response['auth_token'] ?? '',
        userId: response['id'].toString(),
        nombre: response['nombre_completo'] ?? '',
        email: response['email'] ?? '',
        rol: rol,
        refreshToken: response['refresh_token'] ?? '',
        tokenExpiresAt: response['auth_token_expires_at'] ?? '',
      );
      ActivityService.instance.start();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PerfilInternoAdmin(
              perfilData: perfilData,
              rol: rol,
            ),
          ),
        );
      }
    } on ApiException catch (error) {
      _showErrorDialog(error.message);
    } catch (_) {
      _showErrorDialog('Error al iniciar sesión. Verifica tu conexión e intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToRegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistroInternoAdmin()),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                    Icons.admin_panel_settings,
                    size: 60,
                    color: Color(0xFF00A99D),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Acceso Interno',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Inicia sesión con tus credenciales',
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
                          controller: _emailController,
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
                          validator: (value) {
                            if (value!.isEmpty) return 'Campo requerido';
                            if (!value.contains('@')) return 'Ingrese un email válido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
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
                          validator: (value) {
                            if (value!.isEmpty) return 'Campo requerido';
                            if (value.length < 6) return 'Mínimo 6 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF00A99D),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _iniciarSesion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00A99D),
                                  minimumSize: const Size(double.infinity, 55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
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
}