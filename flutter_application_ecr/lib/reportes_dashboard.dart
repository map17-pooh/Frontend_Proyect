import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/pdf_service.dart';

class ReportesDashboard extends StatefulWidget {
  final String rol;
  const ReportesDashboard({super.key, required this.rol});

  @override
  State<ReportesDashboard> createState() => _ReportesDashboardState();
}

class _ReportesDashboardState extends State<ReportesDashboard> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final data = await ApiService.getEstadisticas();
      setState(() {
        _stats = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00A99D)));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 12),
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() { _loading = true; _error = null; });
                _loadStats();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A99D)),
            ),
          ],
        ),
      );
    }

    final stats = _stats!;
    final externos = (stats['usuarios_externos'] as num?)?.toInt() ?? 0;
    final internos = (stats['usuarios_internos'] as num?)?.toInt() ?? 0;
    final admins = (stats['administradores'] as num?)?.toInt() ?? 0;
    final acudientes = (stats['acudientes'] as num?)?.toInt() ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reportes y Estadísticas',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00A99D)),
              ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF00A99D)),
                onPressed: () => PdfService.exportarFormulario(
                  context: context,
                  titulo: 'Estadísticas del Sistema',
                  datos: {
                    'Usuarios externos': '$externos',
                    'Usuarios internos': '$internos',
                    'Administradores': '$admins',
                    'Acudientes': '$acudientes',
                    'Total': '${externos + internos + admins}',
                  },
                ),
                tooltip: 'Exportar PDF',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatCard(label: 'Externos', value: externos, color: Colors.blue),
              const SizedBox(width: 12),
              _StatCard(label: 'Internos', value: internos, color: Colors.green),
              const SizedBox(width: 12),
              _StatCard(label: 'Admins', value: admins, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 24),
          _buildPieChart(externos, internos, admins),
          const SizedBox(height: 24),
          _buildBarChart(externos, internos, admins, acudientes),
        ],
      ),
    );
  }

  Widget _buildPieChart(int externos, int internos, int admins) {
    final total = externos + internos + admins;
    if (total == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Sin datos disponibles'),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Distribución de Usuarios',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: externos.toDouble(),
                    title: '$externos',
                    color: Colors.blue,
                    radius: 80,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: internos.toDouble(),
                    title: '$internos',
                    color: Colors.green,
                    radius: 80,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: admins.toDouble(),
                    title: '$admins',
                    color: Colors.orange,
                    radius: 80,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
                centerSpaceRadius: 30,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegendItem(color: Colors.blue, label: 'Externos'),
              _LegendItem(color: Colors.green, label: 'Internos'),
              _LegendItem(color: Colors.orange, label: 'Admins'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(int externos, int internos, int admins, int acudientes) {
    final maxY = ([externos, internos, admins, acudientes].reduce((a, b) => a > b ? a : b) + 2).toDouble();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Conteo por Categoría',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barGroups: [
                  _barGroup(0, externos.toDouble(), Colors.blue),
                  _barGroup(1, internos.toDouble(), Colors.green),
                  _barGroup(2, admins.toDouble(), Colors.orange),
                  _barGroup(3, acudientes.toDouble(), Colors.purple),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        const labels = ['Ext', 'Int', 'Adm', 'Acu'];
                        final idx = val.toInt();
                        if (idx < 0 || idx >= labels.length) return const SizedBox();
                        return Text(labels[idx], style: const TextStyle(fontSize: 11));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 28,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
