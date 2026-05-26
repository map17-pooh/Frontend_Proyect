import 'package:flutter/material.dart';
import 'perfil_interno_admin.dart';
import 'widgets/custom_widgets.dart';
import 'services/api_service.dart';
import 'services/session_service.dart';

class RegistroInternoAdmin extends StatefulWidget {
  const RegistroInternoAdmin({super.key});

  @override
  State<RegistroInternoAdmin> createState() => _RegistroInternoAdminState();
}

class _RegistroInternoAdminState extends State<RegistroInternoAdmin> {
  String? _selectedRol;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Interno', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF00A99D),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.admin_panel_settings, size: 80, color: Color(0xFF00A99D)),
            const SizedBox(height: 16),
            const Text(
              'Crear Cuenta',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Regístrate como usuario interno o administrador',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // Selector de rol
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selecciona tu rol:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRolCard(
                            title: 'Usuario Interno',
                            icon: Icons.school,
                            color: Colors.green,
                            selected: _selectedRol == 'Interno',
                            onTap: () => setState(() => _selectedRol = 'Interno'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildRolCard(
                            title: 'Administrador',
                            icon: Icons.admin_panel_settings,
                            color: Colors.orange,
                            selected: _selectedRol == 'Administrador',
                            onTap: () => setState(() => _selectedRol = 'Administrador'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Formulario de registro (solo si hay rol seleccionado)
            if (_selectedRol != null)
              _buildRegistroForm(_selectedRol!),
          ],
        ),
      ),
    );
  }

  Widget _buildRolCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: selected ? color : Colors.grey),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistroForm(String rol) {
    final formKey = GlobalKey<FormState>();
    String nombreCompleto = '';
    String email = '';
    String password = '';
    String confirmPassword = '';
    String telefono = '';
    String documento = '';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Datos de registro',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                ),
                onChanged: (value) => nombreCompleto = value,
                validator: validateRequired,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Número de documento',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => documento = value,
                validator: validateNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) => telefono = value,
                validator: validatePhone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => email = value,
                validator: validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                ),
                obscureText: true,
                onChanged: (value) => password = value,
                validator: (value) => validateMinLength(value, 6),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                ),
                obscureText: true,
                onChanged: (value) => confirmPassword = value,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (value != password) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A99D)))
                  : ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        setState(() => _isLoading = true);

                        try {
                          final payload = {
                            'nombre_completo': nombreCompleto,
                            'email': email.trim().toLowerCase(),
                            'password': password,
                            if (rol == 'Interno') 'puesto': documento,
                            if (rol == 'Administrador') 'nivel': documento,
                          };

                          final Map<String, dynamic> response;
                          if (rol == 'Interno') {
                            response = await ApiService.registerInterno(payload);
                          } else {
                            response = await ApiService.registerAdministrador(payload);
                          }

                          final perfilData = {
                            'nombre': response['nombre_completo'] ?? nombreCompleto,
                            'email': response['email'] ?? email,
                            'documento': documento,
                            'telefono': telefono,
                            'rol': rol,
                          };

                          await SessionService.saveSession(
                            token: response['auth_token'] ?? '',
                            userId: response['id'].toString(),
                            nombre: response['nombre_completo'] ?? nombreCompleto,
                            email: response['email'] ?? email,
                            rol: rol,
                          );

                          if (context.mounted) _showSuccessDialog(perfilData, rol);
                        } on ApiException catch (e) {
                          _showErrorDialog(e.message);
                        } catch (_) {
                          _showErrorDialog('Error al registrar. Verifica tu conexión.');
                        } finally {
                          if (context.mounted) setState(() => _isLoading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A99D),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('REGISTRARSE', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
            ],
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

  void _showSuccessDialog(Map<String, dynamic> perfilData, String rol) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [Icon(Icons.check_circle, color: Color(0xFF00A99D)), SizedBox(width: 8), Text('Registro Exitoso')],
        ),
        content: Text('Bienvenido ${perfilData['nombre']}, tu rol es: $rol'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PerfilInternoAdmin(
                    perfilData: perfilData,
                    rol: rol,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A99D)),
            child: const Text('Ir a mi perfil'),
          ),
        ],
      ),
    );
  }
}