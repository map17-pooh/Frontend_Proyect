class UsuarioModel {
  String id;
  String nombreCompleto;
  String email;
  String password;
  String rol; // 'INTERNO', 'ADMIN'
  DateTime? fechaNacimiento;
  String? tipoDocumento;
  String? numeroDocumento;
  DateTime fechaRegistro;
  bool caracterizacionCompletada;
  Map<String, dynamic>? datosSociodemograficos;
  Map<String, dynamic>? datosHistorialClinico;

  UsuarioModel({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.password,
    required this.rol,
    this.fechaNacimiento,
    this.tipoDocumento,
    this.numeroDocumento,
    required this.fechaRegistro,
    this.caracterizacionCompletada = false,
    this.datosSociodemograficos,
    this.datosHistorialClinico,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombreCompleto': nombreCompleto,
      'email': email,
      'password': password,
      'rol': rol,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'tipoDocumento': tipoDocumento,
      'numeroDocumento': numeroDocumento,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'caracterizacionCompletada': caracterizacionCompletada,
      'datosSociodemograficos': datosSociodemograficos,
      'datosHistorialClinico': datosHistorialClinico,
    };
  }

  factory UsuarioModel.fromMap(Map<String, dynamic> map, String id) {
    return UsuarioModel(
      id: id,
      nombreCompleto: map['nombreCompleto'],
      email: map['email'],
      password: map['password'],
      rol: map['rol'],
      fechaNacimiento: map['fechaNacimiento'] != null
          ? DateTime.parse(map['fechaNacimiento'])
          : null,
      tipoDocumento: map['tipoDocumento'],
      numeroDocumento: map['numeroDocumento'],
      fechaRegistro: DateTime.parse(map['fechaRegistro']),
      caracterizacionCompletada: map['caracterizacionCompletada'] ?? false,
      datosSociodemograficos: map['datosSociodemograficos'],
      datosHistorialClinico: map['datosHistorialClinico'],
    );
  }
}