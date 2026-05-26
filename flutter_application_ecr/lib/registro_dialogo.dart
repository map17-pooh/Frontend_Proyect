import 'package:flutter/material.dart';

class RegistroDialogo extends StatefulWidget {
  const RegistroDialogo({super.key});

  @override
  State<RegistroDialogo> createState() => _RegistroDialogoState();
}

class _RegistroDialogoState extends State<RegistroDialogo> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_add, size: 60, color: Color(0xFF00A99D)),
            const SizedBox(height: 16),
            const Text(
              'Registro de Usuario',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
            ),
            const SizedBox(height: 8),
            const Text('Selecciona tu tipo de usuario:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            _buildRoleButton(
              'Usuario Externo',
              Icons.person_outline,
              'Acceso a visualización y caracterización básica',
              Colors.blue,
              () {
                Navigator.pop(context);
                _showRegisterForm('Externo');
              },
            ),
            const SizedBox(height: 12),
            _buildRoleButton(
              'Usuario Interno',
              Icons.school,
              'Puede cambiar información del módulo educativo',
              Colors.green,
              () {
                Navigator.pop(context);
                _showRegisterForm('Interno');
              },
            ),
            const SizedBox(height: 12),
            _buildRoleButton(
              'Administrador',
              Icons.admin_panel_settings,
              'Acceso completo a todas las funcionalidades',
              Colors.orange,
              () {
                Navigator.pop(context);
                _showRegisterForm('Administrador');
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(String title, IconData icon, String description, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color, width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRegisterForm(String role) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String email = '';
    String password = '';
    DateTime? fechaNacimiento;
    bool esMenorEdad = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Registro - Usuario $role', style: const TextStyle(color: Color(0xFF00A99D))),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Nombre completo', prefixIcon: Icon(Icons.person)),
                        onChanged: (value) => name = value,
                        validator: (value) => value == null || value.trim().isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email)),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => email = value,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Campo requerido';
                          final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                          if (!pattern.hasMatch(value.trim())) return 'Ingrese un email válido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      if (role == 'Externo') ...[
                        InkWell(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                fechaNacimiento = picked;
                                final age = DateTime.now().difference(picked).inDays ~/ 365;
                                esMenorEdad = age < 14;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fecha de Nacimiento',
                              prefixIcon: Icon(Icons.cake),
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                            ),
                            child: Text(
                              fechaNacimiento == null 
                                ? 'Seleccione una fecha' 
                                : '${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}',
                              style: TextStyle(color: fechaNacimiento == null ? Colors.grey : Colors.black),
                            ),
                          ),
                        ),
                        if (esMenorEdad) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Registrado como menor de edad',
                                    style: TextStyle(color: Colors.orange, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                        obscureText: true,
                        onChanged: (value) => password = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Campo requerido';
                          if (value.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (role == 'Externo' && fechaNacimiento == null) {
                        _showErrorDialog(context, 'Por favor seleccione su fecha de nacimiento');
                        return;
                      }
                      Navigator.pop(context);
                      String mensaje = 'Bienvenido $name, tu rol es: $role';
                      if (role == 'Externo' && esMenorEdad) {
                        mensaje += '\n\n⚠️ Registrado como menor de edad. Tendrás acceso con supervisión parental.';
                      }
                      _showSuccessDialog(context, 'Registro exitoso', mensaje);
                    }
                  },
                  child: const Text('Registrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A99D)),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF00A99D)),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A99D)),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}