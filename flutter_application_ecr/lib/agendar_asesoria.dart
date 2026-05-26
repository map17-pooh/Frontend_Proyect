import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'services/session_service.dart';

class AgendarAsesoria extends StatefulWidget {
  const AgendarAsesoria({super.key});

  @override
  State<AgendarAsesoria> createState() => _AgendarAsesoriaState();
}

class _AgendarAsesoriaState extends State<AgendarAsesoria> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _horaSeleccionada;
  final TextEditingController _motivoController = TextEditingController();
  bool _isLoading = false;

  final List<String> _horasDisponibles = [
    '9:00 AM', '10:00 AM', '11:00 AM',
    '2:00 PM', '3:00 PM', '4:00 PM',
  ];

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _agendarAsesoria() async {
    if (_selectedDay == null) {
      _showError('Por favor seleccione una fecha');
      return;
    }
    if (_horaSeleccionada == null) {
      _showError('Por favor seleccione una hora');
      return;
    }
    if (_motivoController.text.trim().isEmpty) {
      _showError('Por favor describa el motivo de su consulta');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final session = await SessionService.getSession();
      final fechaStr = '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}';
      await ApiService.crearAsesoria({
        'usuario': int.parse(session?['userId'] ?? '0'),
        'fecha': fechaStr,
        'hora': _horaSeleccionada,
        'motivo': _motivoController.text.trim(),
      });

      final fechaDisplay = '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}';
      await NotificationService.notificarAsesoriaAgendada(fechaDisplay, _horaSeleccionada!);

      if (mounted) _showSuccess();
    } catch (e) {
      _showError('Error al agendar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.error, color: Colors.red), SizedBox(width: 8), Text('Error')
        ]),
        content: Text(msg),
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

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.check_circle, color: Color(0xFF00A99D)),
          SizedBox(width: 8),
          Text('Asesoría Agendada'),
        ]),
        content: const Text(
          'Tu solicitud ha sido registrada. Recibirás una notificación de confirmación.',
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A99D)),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Asesoría', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF00A99D),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecciona una fecha',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 60)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                enabledDayPredicate: (day) => day.weekday != DateTime.sunday,
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF00A99D),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color(0x8000A99D),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Hora disponible',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _horasDisponibles.map((hora) {
                final isSelected = _horaSeleccionada == hora;
                return FilterChip(
                  label: Text(hora),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _horaSeleccionada = hora),
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: const Color(0xFF00A99D),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Motivo de la asesoría',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _motivoController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe brevemente el motivo de tu consulta...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A99D)))
                : ElevatedButton(
                    onPressed: _agendarAsesoria,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A99D),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('SOLICITAR ASESORÍA',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
          ],
        ),
      ),
    );
  }
}
