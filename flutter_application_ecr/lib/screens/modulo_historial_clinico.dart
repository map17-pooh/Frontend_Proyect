import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../widgets/custom_widgets.dart';

class ModuloHistoricoClinicoScreen extends StatefulWidget {
  final UsuarioModel usuario;
  final Map<String, dynamic>? datosPrevios;

  const ModuloHistoricoClinicoScreen({
    super.key,
    required this.usuario,
    this.datosPrevios,
  });

  @override
  State<ModuloHistoricoClinicoScreen> createState() => _ModuloHistoricoClinicoScreenState();
}

class _ModuloHistoricoClinicoScreenState extends State<ModuloHistoricoClinicoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Antecedentes gineco-obstétricos
  bool? haEstadoEmbarazada;
  int? numEmbarazos;
  int? numPartos;
  int? numCesareas;
  int? numAbortos;
  
  // Planificación familiar
  bool? usaAnticonceptivos;
  String? metodoAnticonceptivo;
  String? otrosMetodos;
  
  // ITS
  List<String> itsDiagnosticadas = [];
  final List<String> opcionesITS = [
    'VIH/SIDA',
    'Sífilis',
    'Gonorrea',
    'Clamidia',
    'Herpes Genital',
    'VPH',
    'Hepatitis B',
    'Tricomoniasis',
    'Ninguna'
  ];
  
  // Último examen
  DateTime? fechaUltimoPapanicolau;
  DateTime? fechaUltimoExamenMamas;

  final List<String> metodosAnticonceptivos = [
    'Píldoras anticonceptivas',
    'Parche hormonal',
    'Anillo vaginal',
    'Inyección anticonceptiva',
    'Implante subdérmico',
    'DIU (Cobre/Hormonal)',
    'Condón masculino',
    'Condón femenino',
    'Diafragma',
    'Espermicidas',
    'Método del ritmo',
    'Método de la lactancia',
    'Ligadura de trompas',
    'Vasectomía',
    'Otro'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.datosPrevios != null) {
      haEstadoEmbarazada = widget.datosPrevios!['haEstadoEmbarazada'];
      numEmbarazos = widget.datosPrevios!['numEmbarazos'];
      numPartos = widget.datosPrevios!['numPartos'];
      numCesareas = widget.datosPrevios!['numCesareas'];
      numAbortos = widget.datosPrevios!['numAbortos'];
      usaAnticonceptivos = widget.datosPrevios!['usaAnticonceptivos'];
      metodoAnticonceptivo = widget.datosPrevios!['metodoAnticonceptivo'];
      otrosMetodos = widget.datosPrevios!['otrosMetodos'];
      itsDiagnosticadas = List<String>.from(widget.datosPrevios!['itsDiagnosticadas'] ?? []);
      fechaUltimoPapanicolau = widget.datosPrevios!['fechaUltimoPapanicolau'] != null
          ? DateTime.parse(widget.datosPrevios!['fechaUltimoPapanicolau'])
          : null;
      fechaUltimoExamenMamas = widget.datosPrevios!['fechaUltimoExamenMamas'] != null
          ? DateTime.parse(widget.datosPrevios!['fechaUltimoExamenMamas'])
          : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial Clínico', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF00A99D),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomCard(
              title: 'Antecedentes Gineco-Obstétricos',
              icon: Icons.pregnant_woman,
              child: Column(
                children: [
                  CustomRadioQuestion(
                    question: '¿Ha estado embarazada alguna vez?',
                    value: haEstadoEmbarazada,
                    onChanged: (value) => setState(() => haEstadoEmbarazada = value),
                  ),
                  if (haEstadoEmbarazada == true) ...[
                    const SizedBox(height: 12),
                    CustomTextField(
                      hint: 'Número de embarazos',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => numEmbarazos = int.tryParse(val),
                      validator: (val) => val!.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hint: 'Número de partos',
                      icon: Icons.baby_changing_station,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => numPartos = int.tryParse(val),
                      validator: (value) => value == null || value.isEmpty ? null : validateNumber(value),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hint: 'Número de cesáreas',
                      icon: Icons.medical_services,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => numCesareas = int.tryParse(val),
                      validator: (value) => value == null || value.isEmpty ? null : validateNumber(value),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hint: 'Número de abortos (espontáneos o inducidos)',
                      icon: Icons.warning,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => numAbortos = int.tryParse(val),
                      validator: (value) => value == null || value.isEmpty ? null : validateNumber(value),
                    ),
                  ],
                ],
              ),
            ),
            CustomCard(
              title: 'Planificación Familiar',
              icon: Icons.family_restroom,
              child: Column(
                children: [
                  CustomRadioQuestion(
                    question: '¿Actualmente usa algún método anticonceptivo?',
                    value: usaAnticonceptivos,
                    onChanged: (value) => setState(() => usaAnticonceptivos = value),
                  ),
                  if (usaAnticonceptivos == true) ...[
                    const SizedBox(height: 12),
                    CustomDropdown(
                      hint: 'Método anticonceptivo',
                      items: metodosAnticonceptivos,
                      value: metodoAnticonceptivo,
                      onChanged: (val) => setState(() => metodoAnticonceptivo = val),
                    ),
                    if (metodoAnticonceptivo == 'Otro') ...[
                      const SizedBox(height: 12),
                      CustomTextField(
                        hint: 'Especifique otro método',
                        icon: Icons.edit,
                        onChanged: (val) => otrosMetodos = val,
                      ),
                    ],
                  ],
                ],
              ),
            ),
            CustomCard(
              title: 'Salud Sexual',
              icon: Icons.health_and_safety,
              child: Column(
                children: [
                  CustomChipSelector(
                    label: '¿Ha sido diagnosticada con alguna ITS?',
                    options: opcionesITS,
                    selectedOptions: itsDiagnosticadas,
                    onChanged: (selected) => setState(() => itsDiagnosticadas = selected),
                  ),
                  const SizedBox(height: 16),
                  CustomDatePicker(
                    label: 'Fecha del último Papanicolau',
                    selectedDate: fechaUltimoPapanicolau,
                    onDateSelected: (date) => setState(() => fechaUltimoPapanicolau = date),
                  ),
                  const SizedBox(height: 12),
                  CustomDatePicker(
                    label: 'Fecha del último examen de mamas',
                    selectedDate: fechaUltimoExamenMamas,
                    onDateSelected: (date) => setState(() => fechaUltimoExamenMamas = date),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'GUARDAR Y CONTINUAR',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final datos = {
                    'haEstadoEmbarazada': haEstadoEmbarazada,
                    'numEmbarazos': numEmbarazos,
                    'numPartos': numPartos,
                    'numCesareas': numCesareas,
                    'numAbortos': numAbortos,
                    'usaAnticonceptivos': usaAnticonceptivos,
                    'metodoAnticonceptivo': metodoAnticonceptivo,
                    'otrosMetodos': otrosMetodos,
                    'itsDiagnosticadas': itsDiagnosticadas,
                    'fechaUltimoPapanicolau': fechaUltimoPapanicolau?.toIso8601String(),
                    'fechaUltimoExamenMamas': fechaUltimoExamenMamas?.toIso8601String(),
                  };
                  Navigator.pop(context, datos);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}