import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../widgets/custom_widgets.dart';

class ModuloSociodemograficoScreen extends StatefulWidget {
  final UsuarioModel usuario;
  final Map<String, dynamic>? datosPrevios;

  const ModuloSociodemograficoScreen({
    super.key,
    required this.usuario,
    this.datosPrevios,
  });

  @override
  State<ModuloSociodemograficoScreen> createState() => _ModuloSociodemograficoScreenState();
}

class _ModuloSociodemograficoScreenState extends State<ModuloSociodemograficoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late String nombreCompleto;
  String? tipoDocumento;
  String? numeroDocumento;
  DateTime? fechaNacimiento;
  String? estadoCivil;
  String? estrato;
  String? ocupacion;
  String? nivelEducativo;
  String? institucion;
  String? zonaResidencia;
  String? municipio;
  String? direccion;

  final List<String> tiposDocumento = [
    'Cédula de Ciudadanía', 'Tarjeta de Identidad', 'Cédula de Extranjería', 'Pasaporte', 'Registro Civil'
  ];

  final List<String> estadosCiviles = [
    'Soltero/a', 'Casado/a', 'Unión libre', 'Divorciado/a', 'Viudo/a', 'Separado/a'
  ];

  final List<String> estratos = ['1', '2', '3', '4', '5', '6'];

  final List<String> nivelesEducativos = [
    'Ninguno', 'Primaria', 'Secundaria', 'Técnico', 'Tecnólogo', 'Universitario', 'Posgrado'
  ];

  final List<String> zonasResidencia = ['Urbana', 'Rural'];

  final List<String> municipiosCundinamarca = [
    'Agua de Dios', 'Albán', 'Anapoima', 'Anolaima', 'Apulo', 'Arbeláez', 'Beltrán', 'Bituima', 'Bogotá D.C.', 'Bojacá',
    'Cabrera', 'Cachipay', 'Cajicá', 'Caparrapí', 'Cáqueza', 'Carmen de Carupa', 'Chaguaní', 'Chía', 'Chipaque', 'Choachí',
    'Chocontá', 'Cogua', 'Cota', 'Cucunubá', 'El Colegio', 'El Peñón', 'El Rosal', 'Facatativá', 'Fómeque', 'Fosca',
    'Funza', 'Fúquene', 'Fusagasugá', 'Gachalá', 'Gachancipá', 'Gachetá', 'Gama', 'Girardot', 'Granada', 'Guachetá',
    'Guaduas', 'Guasca', 'Guataquí', 'Guatavita', 'Guayabal de Síquima', 'Guayabetal', 'Gutiérrez', 'Jerusalén', 'Junín',
    'La Calera', 'La Mesa', 'La Palma', 'La Peña', 'La Vega', 'Lenguazaque', 'Machetá', 'Madrid', 'Manta', 'Medina',
    'Mosquera', 'Nariño', 'Nemocón', 'Nilo', 'Nimaima', 'Nocaima', 'Pacho', 'Paime', 'Pandi', 'Paratebueno', 'Pasca',
    'Puerto Salgar', 'Pulí', 'Quebradanegra', 'Quetame', 'Quipile', 'Ricaurte', 'San Antonio del Tequendama', 'San Bernardo',
    'San Cayetano', 'San Francisco', 'San Juan de Río Seco', 'Sasaima', 'Sesquilé', 'Sibaté', 'Silvania', 'Simijaca',
    'Soacha', 'Sopó', 'Subachoque', 'Suesca', 'Supatá', 'Susa', 'Sutatausa', 'Tabio', 'Tausa', 'Tena', 'Tenjo', 'Tibacuy',
    'Tibirita', 'Tocaima', 'Tocancipá', 'Topaipí', 'Ubalá', 'Ubaque', 'Villa de San Diego de Ubate', 'Une', 'Útica',
    'Venecia', 'Vergara', 'Vianí', 'Villagómez', 'Villapinzón', 'Villeta', 'Viotá', 'Yacopí', 'Zipacón', 'Zipaquirá'
  ];

  @override
  void initState() {
    super.initState();
    nombreCompleto = widget.usuario.nombreCompleto;
    tipoDocumento = widget.usuario.tipoDocumento;
    numeroDocumento = widget.usuario.numeroDocumento;
    fechaNacimiento = widget.usuario.fechaNacimiento;
    
    if (widget.datosPrevios != null) {
      estadoCivil = widget.datosPrevios!['estadoCivil'];
      estrato = widget.datosPrevios!['estrato'];
      ocupacion = widget.datosPrevios!['ocupacion'];
      nivelEducativo = widget.datosPrevios!['nivelEducativo'];
      institucion = widget.datosPrevios!['institucion'];
      zonaResidencia = widget.datosPrevios!['zonaResidencia'];
      municipio = widget.datosPrevios!['municipio'];
      direccion = widget.datosPrevios!['direccion'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo Sociodemográfico', style: TextStyle(color: Colors.white)),
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
              title: 'Información Básica',
              icon: Icons.person,
              child: Column(
                children: [
                  CustomTextField(
                    hint: 'Nombre Completo',
                    icon: Icons.badge,
                    onChanged: (val) => nombreCompleto = val,
                    validator: (val) => val!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomDropdown(
                    hint: 'Tipo de Documento',
                    items: tiposDocumento,
                    value: tipoDocumento,
                    onChanged: (val) => tipoDocumento = val,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hint: 'Número de Documento',
                    icon: Icons.numbers,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => numeroDocumento = val,
                    validator: (val) => val!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomDatePicker(
                    label: 'Fecha de Nacimiento',
                    selectedDate: fechaNacimiento,
                    onDateSelected: (date) => fechaNacimiento = date,
                    validator: validateDate,
                  ),
                ],
              ),
            ),
            CustomCard(
              title: 'Aspectos Socioeconómicos',
              icon: Icons.home_work,
              child: Column(
                children: [
                  CustomDropdown(
                    hint: 'Estado Civil',
                    items: estadosCiviles,
                    value: estadoCivil,
                    onChanged: (val) => estadoCivil = val,
                  ),
                  const SizedBox(height: 12),
                  CustomDropdown(
                    hint: 'Estrato Socioeconómico',
                    items: estratos,
                    value: estrato,
                    onChanged: (val) => estrato = val,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hint: 'Ocupación',
                    icon: Icons.work,
                    onChanged: (val) => ocupacion = val,
                    validator: validateRequired,
                  ),
                ],
              ),
            ),
            CustomCard(
              title: 'Educación',
              icon: Icons.school,
              child: Column(
                children: [
                  CustomDropdown(
                    hint: 'Nivel Educativo',
                    items: nivelesEducativos,
                    value: nivelEducativo,
                    onChanged: (val) => nivelEducativo = val,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hint: 'Institución Educativa',
                    icon: Icons.account_balance,
                    onChanged: (val) => institucion = val,
                    validator: validateRequired,
                  ),
                ],
              ),
            ),
            CustomCard(
              title: 'Ubicación',
              icon: Icons.map,
              child: Column(
                children: [
                  CustomDropdown(
                    hint: 'Zona de Residencia',
                    items: zonasResidencia,
                    value: zonaResidencia,
                    onChanged: (val) => zonaResidencia = val,
                  ),
                  const SizedBox(height: 12),
                  CustomDropdown(
                    hint: 'Municipio de Cundinamarca',
                    items: municipiosCundinamarca,
                    value: municipio,
                    onChanged: (val) => municipio = val,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hint: 'Dirección',
                    icon: Icons.location_on,
                    onChanged: (val) => direccion = val,
                    validator: validateRequired,
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
                    'nombreCompleto': nombreCompleto,
                    'tipoDocumento': tipoDocumento,
                    'numeroDocumento': numeroDocumento,
                    'fechaNacimiento': fechaNacimiento?.toIso8601String(),
                    'estadoCivil': estadoCivil,
                    'estrato': estrato,
                    'ocupacion': ocupacion,
                    'nivelEducativo': nivelEducativo,
                    'institucion': institucion,
                    'zonaResidencia': zonaResidencia,
                    'municipio': municipio,
                    'direccion': direccion,
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