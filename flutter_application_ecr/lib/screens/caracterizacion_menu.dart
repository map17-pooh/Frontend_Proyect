import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../widgets/custom_widgets.dart';
import 'modulo_sociodemografico.dart';
import 'modulo_historial_clinico.dart';

class CaracterizacionMenuScreen extends StatefulWidget {
  final UsuarioModel usuario;
  final Function(Map<String, dynamic>, Map<String, dynamic>) onCompletada;

  const CaracterizacionMenuScreen({
    super.key,
    required this.usuario,
    required this.onCompletada,
  });

  @override
  State<CaracterizacionMenuScreen> createState() => _CaracterizacionMenuScreenState();
}

class _CaracterizacionMenuScreenState extends State<CaracterizacionMenuScreen> {
  bool _sociodemograficoCompletado = false;
  bool _historicoClinicoCompletado = false;
  Map<String, dynamic>? _datosSociodemograficos;
  Map<String, dynamic>? _datosHistorialClinico;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caracterización', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF00A99D),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completa los siguientes módulos para finalizar tu caracterización:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            _buildModuloCard(
              numero: 1,
              titulo: 'Módulo Sociodemográfico',
              descripcion: 'Información personal, ubicación, educación y aspectos socioeconómicos',
              icon: Icons.person_outline,
              completado: _sociodemograficoCompletado,
              onPressed: () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModuloSociodemograficoScreen(
                      usuario: widget.usuario,
                      datosPrevios: _datosSociodemograficos,
                    ),
                  ),
                );
                if (resultado != null) {
                  setState(() {
                    _datosSociodemograficos = resultado;
                    _sociodemograficoCompletado = true;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            _buildModuloCard(
              numero: 2,
              titulo: 'Módulo Historial Clínico',
              descripcion: 'Antecedentes gineco-obstétricos, planificación familiar y salud sexual',
              icon: Icons.health_and_safety,
              completado: _historicoClinicoCompletado,
              onPressed: _sociodemograficoCompletado
                  ? () async {
                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModuloHistoricoClinicoScreen(
                            usuario: widget.usuario,
                            datosPrevios: _datosHistorialClinico,
                          ),
                        ),
                      );
                      if (resultado != null) {
                        setState(() {
                          _datosHistorialClinico = resultado;
                          _historicoClinicoCompletado = true;
                        });
                      }
                    }
                  : null,
            ),
            const Spacer(),
            if (_sociodemograficoCompletado && _historicoClinicoCompletado)
              CustomButton(
                text: 'FINALIZAR CARACTERIZACIÓN',
                onPressed: () {
                  widget.onCompletada(
                    _datosSociodemograficos!,
                    _datosHistorialClinico!,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Caracterización completada exitosamente!'),
                      backgroundColor: Color(0xFF00A99D),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuloCard({
    required int numero,
    required String titulo,
    required String descripcion,
    required IconData icon,
    required bool completado,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: completado ? Colors.green.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: completado ? Colors.green : const Color(0xFF00A99D).withOpacity(0.3),
          width: completado ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: completado
                      ? [Colors.green, Colors.green.withOpacity(0.7)]
                      : [const Color(0xFF00A99D), const Color(0xFF00A99D).withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: completado
                    ? const Icon(Icons.check, color: Colors.white, size: 28)
                    : Text(
                        '$numero',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(descripcion, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            if (onPressed != null && !completado)
              IconButton(
                onPressed: onPressed,
                icon: const Icon(Icons.arrow_forward, color: Color(0xFF00A99D)),
              ),
            if (completado)
              const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}