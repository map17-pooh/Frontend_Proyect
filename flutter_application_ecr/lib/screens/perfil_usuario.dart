import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../widgets/custom_widgets.dart';
import 'caracterizacion_menu.dart';

class PerfilUsuarioScreen extends StatefulWidget {
  final UsuarioModel usuario;

  const PerfilUsuarioScreen({super.key, required this.usuario});

  @override
  State<PerfilUsuarioScreen> createState() => _PerfilUsuarioScreenState();
}

class _PerfilUsuarioScreenState extends State<PerfilUsuarioScreen> {
  late UsuarioModel _usuario;

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuario;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF00A99D),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildInfoCard(),
            const SizedBox(height: 20),
            if (!_usuario.caracterizacionCompletada)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomButton(
                  text: 'INICIAR CARACTERIZACIÓN',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CaracterizacionMenuScreen(
                          usuario: _usuario,
                          onCompletada: (datosSociodemograficos, datosHistorialClinico) {
                            setState(() {
                              _usuario.caracterizacionCompletada = true;
                              _usuario.datosSociodemograficos = datosSociodemograficos;
                              _usuario.datosHistorialClinico = datosHistorialClinico;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (_usuario.caracterizacionCompletada)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomButton(
                  text: 'VER CARACTERIZACIÓN COMPLETADA',
                  onPressed: () => _showCaracterizacionResumen(),
                  isOutlined: true,
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00A99D),
            const Color(0xFF00A99D).withOpacity(0.7),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.person, size: 60, color: Color(0xFF00A99D)),
          ),
          const SizedBox(height: 16),
          Text(
            _usuario.nombreCompleto,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _usuario.rol,
              style: const TextStyle(color: Color(0xFF00A99D), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return CustomCard(
      title: 'Información Personal',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildInfoRow(Icons.email, 'Correo electrónico', _usuario.email),
          const SizedBox(height: 12),
          if (_usuario.tipoDocumento != null)
            _buildInfoRow(Icons.badge, 'Tipo de documento', _usuario.tipoDocumento!),
          const SizedBox(height: 12),
          if (_usuario.numeroDocumento != null)
            _buildInfoRow(Icons.numbers, 'Número de documento', _usuario.numeroDocumento!),
          const SizedBox(height: 12),
          if (_usuario.fechaNacimiento != null)
            _buildInfoRow(
              Icons.cake,
              'Fecha de nacimiento',
              '${_usuario.fechaNacimiento!.day}/${_usuario.fechaNacimiento!.month}/${_usuario.fechaNacimiento!.year}',
            ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            'Fecha de registro',
            '${_usuario.fechaRegistro.day}/${_usuario.fechaRegistro.month}/${_usuario.fechaRegistro.year}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.assignment_turned_in,
            'Estado de caracterización',
            _usuario.caracterizacionCompletada ? 'Completada' : 'Pendiente',
            iconColor: _usuario.caracterizacionCompletada ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor ?? const Color(0xFF00A99D)),
        const SizedBox(width: 12),
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
      ],
    );
  }

  void _showCaracterizacionResumen() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Resumen de Caracterización'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Módulo Sociodemográfico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text('Nombre: ${_usuario.datosSociodemograficos?['nombreCompleto'] ?? 'N/A'}'),
                Text('Documento: ${_usuario.datosSociodemograficos?['tipoDocumento']} ${_usuario.datosSociodemograficos?['numeroDocumento']}'),
                Text('Estado Civil: ${_usuario.datosSociodemograficos?['estadoCivil'] ?? 'N/A'}'),
                Text('Estrato: ${_usuario.datosSociodemograficos?['estrato'] ?? 'N/A'}'),
                Text('Ocupación: ${_usuario.datosSociodemograficos?['ocupacion'] ?? 'N/A'}'),
                Text('Nivel Educativo: ${_usuario.datosSociodemograficos?['nivelEducativo'] ?? 'N/A'}'),
                Text('Institución: ${_usuario.datosSociodemograficos?['institucion'] ?? 'N/A'}'),
                Text('Zona: ${_usuario.datosSociodemograficos?['zonaResidencia'] ?? 'N/A'}'),
                Text('Municipio: ${_usuario.datosSociodemograficos?['municipio'] ?? 'N/A'}'),
                Text('Dirección: ${_usuario.datosSociodemograficos?['direccion'] ?? 'N/A'}'),
                const SizedBox(height: 16),
                const Text('Módulo Historial Clínico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text('¿Ha estado embarazada? ${_usuario.datosHistorialClinico?['haEstadoEmbarazada'] == true ? 'Sí' : 'No'}'),
                if (_usuario.datosHistorialClinico?['haEstadoEmbarazada'] == true) ...[
                  Text('Número de embarazos: ${_usuario.datosHistorialClinico?['numEmbarazos'] ?? 'N/A'}'),
                  Text('Número de partos: ${_usuario.datosHistorialClinico?['numPartos'] ?? 'N/A'}'),
                  Text('Número de cesáreas: ${_usuario.datosHistorialClinico?['numCesareas'] ?? 'N/A'}'),
                  Text('Número de abortos: ${_usuario.datosHistorialClinico?['numAbortos'] ?? 'N/A'}'),
                ],
                Text('Uso de anticonceptivos: ${_usuario.datosHistorialClinico?['usaAnticonceptivos'] == true ? 'Sí' : 'No'}'),
                if (_usuario.datosHistorialClinico?['usaAnticonceptivos'] == true)
                  Text('Método anticonceptivo: ${_usuario.datosHistorialClinico?['metodoAnticonceptivo'] ?? 'N/A'}'),
                Text('ITS diagnosticadas: ${_usuario.datosHistorialClinico?['itsDiagnosticadas'] ?? 'Ninguna'}'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
          ],
        );
      },
    );
  }
}