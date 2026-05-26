import 'package:flutter/material.dart';

class GestionUsuarios extends StatelessWidget {
  final String rol;

  const GestionUsuarios({super.key, required this.rol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                rol == 'Administrador' ? Icons.people_alt : Icons.people,
                size: 80,
                color: const Color(0xFF00A99D),
              ),
              const SizedBox(height: 20),
              Text(
                rol == 'Administrador' 
                    ? 'Gestión de Usuarios del Sistema' 
                    : 'Gestión de Usuarios Externos',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                rol == 'Administrador'
                    ? 'Módulo en desarrollo. Aquí podrás gestionar todos los usuarios del sistema, incluyendo sus roles y permisos.'
                    : 'Módulo en desarrollo. Aquí podrás ver y gestionar los usuarios externos registrados.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A99D),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}