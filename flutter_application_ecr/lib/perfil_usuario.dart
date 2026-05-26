import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/custom_widgets.dart';
import 'formulario_caracterizacion.dart';
import 'historial_clinico.dart';
import 'modulo_educativo.dart';

class PerfilUsuario extends StatefulWidget {
  final String rol;
  final String email;

  const PerfilUsuario({
    super.key,
    required this.rol,
    required this.email,
  });

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  final _formKey = GlobalKey<FormState>();
  bool _perfilCompletado = false;
  
  // Datos del perfil
  String nombreCompleto = '';
  String tipoDocumento = '';
  String numeroDocumento = '';
  DateTime? fechaNacimiento;
  String telefono = '';
  String direccion = '';

  final List<String> tiposDocumento = [
    'Cédula de Ciudadanía', 'Tarjeta de Identidad', 'Cédula de Extranjería', 'Pasaporte', 'Registro Civil'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil - ${widget.rol}', style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF00A99D),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _perfilCompletado ? _buildModulos() : _buildFormularioPerfil(),
    );
  }

  Widget _buildFormularioPerfil() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Icon(Icons.person, size: 80, color: Color(0xFF00A99D)),
            const SizedBox(height: 20),
            const Text(
              'Completa tu perfil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
            ),
            const SizedBox(height: 10),
            const Text(
              'Registra tus datos personales para acceder a los módulos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            _buildTextField(
              'Nombre Completo',
              Icons.person,
              (v) => nombreCompleto = v,
              validator: validateRequired,
            ),
            const SizedBox(height: 15),
            _buildDropdown('Tipo de Documento', tiposDocumento, (v) => tipoDocumento = v!),
            const SizedBox(height: 15),
            _buildTextField(
              'Número de Documento',
              Icons.numbers,
              (v) => numeroDocumento = v,
              keyboardType: TextInputType.number,
              validator: validateNumber,
            ),
            const SizedBox(height: 15),
            _buildFechaNacimiento(),
            const SizedBox(height: 15),
            _buildTextField(
              'Teléfono',
              Icons.phone,
              (v) => telefono = v,
              keyboardType: TextInputType.phone,
              validator: validatePhone,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              'Dirección',
              Icons.location_on,
              (v) => direccion = v,
              validator: validateRequired,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (fechaNacimiento == null) {
                    _showErrorDialog('Por favor seleccione su fecha de nacimiento');
                    return;
                  }
                  setState(() {
                    _perfilCompletado = true;
                  });
                  _showSuccessDialog('Perfil creado', '¡Tu perfil ha sido creado exitosamente!');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A99D),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('CREAR PERFIL', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulos() {
    return Column(
      children: [
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
                nombreCompleto,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                tipoDocumento,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.all(20),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildModuloCard(
                titulo: 'Caracterización Sociodemográfica',
                icon: Icons.assignment_ind,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FormularioCaracterizacion()),
                  );
                },
              ),
              _buildModuloCard(
                titulo: 'Historial Clínico',
                icon: Icons.health_and_safety,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistorialClinico()),
                  );
                },
              ),
              _buildModuloCard(
                titulo: 'Módulo Educativo',
                icon: Icons.school,
                color: const Color(0xFF00A99D),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ModuloEducativo()),
                  );
                },
              ),
              if (widget.rol == 'Administrador')
                _buildModuloCard(
                  titulo: 'Panel de Control',
                  icon: Icons.dashboard,
                  color: Colors.orange,
                  onTap: () {
                    _showInfoDialog('Panel de Control', 'Acceso exclusivo para administradores');
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModuloCard({
    required String titulo,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    Function(String) onChanged, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00A99D)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number ? [FilteringTextInputFormatter.digitsOnly] : null,
      onChanged: onChanged,
      validator: validator ?? (value) => value!.isEmpty ? 'Campo requerido' : null,
    );
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.arrow_drop_down_circle, color: Color(0xFF00A99D)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Seleccione una opción' : null,
    );
  }

  Widget _buildFechaNacimiento() {
    return InkWell(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            fechaNacimiento = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha de Nacimiento',
          prefixIcon: Icon(Icons.cake, color: Color(0xFF00A99D)),
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          fechaNacimiento == null 
            ? 'Seleccione una fecha' 
            : '${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}',
          style: TextStyle(color: fechaNacimiento == null ? Colors.grey : Colors.black),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [Icon(Icons.error, color: Colors.red), SizedBox(width: 8), Text('Error')],
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

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: Color(0xFF00A99D))),
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
}