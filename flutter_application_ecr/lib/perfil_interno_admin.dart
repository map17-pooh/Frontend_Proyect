import 'package:flutter/material.dart';
import 'modulo_educativo.dart';
import 'formulario_caracterizacion.dart';
import 'historial_clinico.dart';
import 'gestion_usuarios.dart';
import 'reportes_dashboard.dart';
import 'menu_inicio.dart';
import 'services/activity_service.dart';
import 'services/session_service.dart';

class PerfilInternoAdmin extends StatefulWidget {
  final Map<String, dynamic> perfilData;
  final String rol;

  const PerfilInternoAdmin({
    super.key,
    required this.perfilData,
    required this.rol,
  });

  @override
  State<PerfilInternoAdmin> createState() => _PerfilInternoAdminState();
}

class _PerfilInternoAdminState extends State<PerfilInternoAdmin> {
  int _selectedIndex = 0;
  
  late List<Widget> _paginas;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    
    // Configurar páginas según el rol
    if (widget.rol == 'Administrador') {
      _paginas = [
        const ModuloEducativo(),
        GestionUsuarios(rol: widget.rol),
        ReportesDashboard(rol: widget.rol),
        _buildPerfilContent(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Educativo'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reportes'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ];
    } else {
      // Usuario Interno
      _paginas = [
        const ModuloEducativo(),
        GestionUsuarios(rol: widget.rol),
        _buildPerfilContent(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Educativo'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ];
    }
  }

  Widget _buildPerfilContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF00A99D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: widget.rol == 'Administrador' 
                      ? Colors.orange 
                      : Colors.green,
                  child: Icon(
                    widget.rol == 'Administrador' 
                        ? Icons.admin_panel_settings 
                        : Icons.school,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.perfilData['nombre'] ?? '',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.rol == 'Administrador' 
                        ? Colors.orange.withOpacity(0.2) 
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.rol,
                    style: TextStyle(
                      color: widget.rol == 'Administrador' ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(widget.perfilData['email'] ?? ''),
                Text('Documento: ${widget.perfilData['documento'] ?? ''}'),
                Text('Teléfono: ${widget.perfilData['telefono'] ?? ''}'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (widget.rol == 'Interno') ...[
            _buildSectionCard(
              title: 'Gestión Educativa',
              icon: Icons.school,
              children: [
                _buildOptionButton(
                  title: 'Módulo Educativo',
                  subtitle: 'Ver y gestionar contenido educativo',
                  icon: Icons.library_books,
                  color: const Color(0xFF00A99D),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _buildOptionButton(
                  title: 'Gestionar Usuarios Externos',
                  subtitle: 'Ver listado y estadísticas de usuarios',
                  icon: Icons.people,
                  color: Colors.blue,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
              ],
            ),
          ],
          if (widget.rol == 'Administrador') ...[
            _buildSectionCard(
              title: 'Panel de Control',
              icon: Icons.dashboard,
              children: [
                _buildOptionButton(
                  title: 'Módulo Educativo',
                  subtitle: 'Gestionar contenido educativo',
                  icon: Icons.library_books,
                  color: const Color(0xFF00A99D),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _buildOptionButton(
                  title: 'Gestión de Usuarios',
                  subtitle: 'Administrar todos los usuarios del sistema',
                  icon: Icons.admin_panel_settings,
                  color: Colors.orange,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _buildOptionButton(
                  title: 'Reportes y Estadísticas',
                  subtitle: 'Ver métricas del sistema',
                  icon: Icons.bar_chart,
                  color: Colors.purple,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          _buildSectionCard(
            title: 'Seguridad',
            icon: Icons.security,
            children: [
              _buildOptionButton(
                title: 'Cambiar Contraseña',
                subtitle: 'Actualizar tu contraseña',
                icon: Icons.lock_reset,
                color: Colors.grey,
                onTap: () {
                  _showChangePasswordDialog();
                },
              ),
              const SizedBox(height: 12),
              _buildOptionButton(
                title: 'Cerrar Sesión',
                subtitle: 'Salir de la aplicación',
                icon: Icons.logout,
                color: Colors.red,
                onTap: () {
                  _cerrarSesion();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A99D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: const Color(0xFF00A99D), size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00A99D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF00A99D)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final formKey = GlobalKey<FormState>();
    String currentPassword = '';
    String newPassword = '';
    String confirmPassword = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cambiar Contraseña', style: TextStyle(color: Color(0xFF00A99D))),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Contraseña actual',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                onChanged: (v) => currentPassword = v,
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                onChanged: (v) => newPassword = v,
                validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                onChanged: (v) => confirmPassword = v,
                validator: (v) {
                  if (v!.isEmpty) return 'Campo requerido';
                  if (v != newPassword) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                _showSuccessDialog('Contraseña actualizada', 'Tu contraseña ha sido cambiada exitosamente');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A99D)),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _cerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              ActivityService.instance.stop();
              await SessionService.clearSession();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuInicio()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [const Icon(Icons.check_circle, color: Color(0xFF00A99D)), const SizedBox(width: 8), Text(title)],
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
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'PreventApp - ${widget.rol}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00A99D),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              setState(() {
                _selectedIndex = widget.rol == 'Administrador' ? 3 : 2;
              });
            },
          ),
        ],
      ),
      body: _paginas[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _navItems,
        selectedItemColor: const Color(0xFF00A99D),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    ),
    );
  }
}