import 'package:flutter/material.dart';
import 'formulario_caracterizacion.dart';
import 'modulo_educativo.dart';
import 'agendar_asesoria.dart';
import 'menu_inicio.dart';
import 'services/activity_service.dart';
import 'services/session_service.dart';
import 'services/pdf_service.dart';

class PerfilUsuarioExterno extends StatefulWidget {
  final Map<String, dynamic> perfilData;

  const PerfilUsuarioExterno({super.key, required this.perfilData});

  @override
  State<PerfilUsuarioExterno> createState() => _PerfilUsuarioExternoState();
}

class _PerfilUsuarioExternoState extends State<PerfilUsuarioExterno> {
  bool caracterizacionCompletada = false;

  void _cerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF00A99D),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: () => PdfService.exportarPerfil(
              context: context,
              perfilData: widget.perfilData,
            ),
            tooltip: 'Exportar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          // Información del perfil
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF00A99D).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF00A99D),
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.perfilData['nombre'] ?? '',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.perfilData['email'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.perfilData['tipoDocumento']} - ${widget.perfilData['numeroDocumento']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                _buildProgressBar(),
                if (widget.perfilData['esMenor14'] == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Menor de edad - Con acudiente',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Módulos
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Módulos disponibles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildModuloCard(
                          titulo: 'Caracterización Sociodemográfica',
                          subtitulo: caracterizacionCompletada ? '✓ Completada' : 'Pendiente',
                          icon: Icons.assignment_ind,
                          color: Colors.blue,
                          completado: caracterizacionCompletada,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FormularioCaracterizacion()),
                            );
                            if (result == true) {
                              setState(() {
                                caracterizacionCompletada = true;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildModuloCard(
                          titulo: 'Módulo Educativo',
                          subtitulo: 'Información y recursos',
                          icon: Icons.school,
                          color: const Color(0xFF00A99D),
                          completado: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ModuloEducativo()),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        if (caracterizacionCompletada)
                          _buildModuloCard(
                            titulo: 'Agendar Asesoría Presencial',
                            subtitulo: 'Solicita una cita con nuestros especialistas',
                            icon: Icons.calendar_today,
                            color: Colors.orange,
                            completado: false,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AgendarAsesoria()),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildProgressBar() {
    int completed = 0;
    const total = 3;
    if (caracterizacionCompletada) completed++;
    final progress = completed / total;
    final pct = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Progreso del perfil',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('$pct% ($completed/$total)',
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00A99D),
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            color: const Color(0xFF00A99D),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildModuloCard({
    required String titulo,
    required String subtitulo,
    required IconData icon,
    required Color color,
    required bool completado,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 30, color: color),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitulo),
        trailing: completado
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}