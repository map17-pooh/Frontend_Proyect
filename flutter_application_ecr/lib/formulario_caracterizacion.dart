import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/custom_widgets.dart';
import 'historial_clinico.dart';
import 'services/api_service.dart';
import 'services/session_service.dart';

class FormularioCaracterizacion extends StatefulWidget {
  const FormularioCaracterizacion({super.key});

  @override
  State<FormularioCaracterizacion> createState() => _FormularioCaracterizacionState();
}

class _FormularioCaracterizacionState extends State<FormularioCaracterizacion> {
  final _formKey = GlobalKey<FormState>();

  // ── Session / loading ──────────────────────────────────────────────────────
  String? _userId;
  bool _isLoading = true;
  bool _isInitializing = true;
  bool _isSaving = false;
  bool _tieneCaracterizacionExistente = false;

  // ── Dropdowns ──────────────────────────────────────────────────────────────
  String? sexoBiologico;           // Hombre / Mujer (condicional clínico)
  String? sexoSeleccionado;        // identidad de género
  String? tipoDocumentoSeleccionado;
  String? estadoCivilSeleccionado;
  String? nivelEducativo;
  String? zonaResidencia;
  String? municipioSeleccionado;
  String? consumeAlcohol;
  String? consumeTabaco;

  // ── Fechas ─────────────────────────────────────────────────────────────────
  DateTime? fechaNacimiento;
  DateTime? fechaUltimaCitologia;

  // ── Booleans ───────────────────────────────────────────────────────────────
  bool mostrarOtroSexo = false;
  bool? _haRealizadoCitologia;
  bool? _enGestacion;
  bool? _enLactancia;
  bool? _tieneHijos;
  bool? _vivenSolo;
  bool? _dificultadMovilidad;
  bool? _polifarmacia;
  bool? _vidaSexualActiva;
  String? _metodoProteccion;
  bool? _pruebaEts;

  // ── Controllers ────────────────────────────────────────────────────────────
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _numDocumentoCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _estratoCtrl;
  late final TextEditingController _ocupacionCtrl;
  late final TextEditingController _institucionCtrl;
  late final TextEditingController _identidadOtroCtrl;
  late final TextEditingController _epsIpsCtrl;
  late final TextEditingController _numEmbarazosCtrl;
  late final TextEditingController _numPartosCtrl;
  late final TextEditingController _numCesareasCtrl;
  late final TextEditingController _numAbortosCtrl;
  late final TextEditingController _numHijosCtrl;
  late final TextEditingController _redApoyoCtrl;
  late final TextEditingController _caidasCtrl;
  late final TextEditingController _numParejasActualesCtrl;
  late final TextEditingController _numParejasAnioCtrl;

  String get _draftKey => 'draft_caracterizacion_${_userId ?? 'anon'}';

  // ── Computed conditionals ──────────────────────────────────────────────────
  bool get _esMasculino => sexoBiologico == 'Hombre';

  bool get _mostrarCamposFemeninos =>
      sexoBiologico == null || sexoBiologico == 'Mujer';

  int? get _edad {
    if (fechaNacimiento == null) return null;
    final now = DateTime.now();
    int age = now.year - fechaNacimiento!.year;
    if (now.month < fechaNacimiento!.month ||
        (now.month == fechaNacimiento!.month && now.day < fechaNacimiento!.day)) {
      age--;
    }
    return age;
  }

  bool get _esMenor12 => _edad != null && _edad! < 12;
  bool get _esMenor18 => _edad != null && _edad! < 18;
  bool get _esMayor60 => _edad != null && _edad! >= 60;

  List<TextEditingController> get _allControllers => [
        _nombreCtrl, _numDocumentoCtrl, _direccionCtrl, _estratoCtrl,
        _ocupacionCtrl, _institucionCtrl, _identidadOtroCtrl, _epsIpsCtrl,
        _numEmbarazosCtrl, _numPartosCtrl, _numCesareasCtrl, _numAbortosCtrl,
        _numHijosCtrl,
        _redApoyoCtrl, _caidasCtrl,
        _numParejasActualesCtrl, _numParejasAnioCtrl,
      ];

  // ── Listas ─────────────────────────────────────────────────────────────────
  final List<String> _municipiosCundinamarca = [
    'Agua de Dios', 'Albán', 'Anapoima', 'Anolaima', 'Apulo', 'Arbeláez',
    'Beltrán', 'Bituima', 'Bogotá D.C.', 'Bojacá', 'Cabrera', 'Cachipay',
    'Cajicá', 'Caparrapí', 'Cáqueza', 'Carmen de Carupa', 'Chaguaní', 'Chía',
    'Chipaque', 'Choachí', 'Chocontá', 'Cogua', 'Cota', 'Cucunubá',
    'El Colegio', 'El Peñón', 'El Rosal', 'Facatativá', 'Fómeque', 'Fosca',
    'Funza', 'Fúquene', 'Fusagasugá', 'Gachalá', 'Gachancipá', 'Gachetá',
    'Gama', 'Girardot', 'Granada', 'Guachetá', 'Guaduas', 'Guasca',
    'Guataquí', 'Guatavita', 'Guayabal de Síquima', 'Guayabetal', 'Gutiérrez',
    'Jerusalén', 'Junín', 'La Calera', 'La Mesa', 'La Palma', 'La Peña',
    'La Vega', 'Lenguazaque', 'Machetá', 'Madrid', 'Manta', 'Medina',
    'Mosquera', 'Nariño', 'Nemocón', 'Nilo', 'Nimaima', 'Nocaima', 'Pacho',
    'Paime', 'Pandi', 'Paratebueno', 'Pasca', 'Puerto Salgar', 'Pulí',
    'Quebradanegra', 'Quetame', 'Quipile', 'Ricaurte',
    'San Antonio del Tequendama', 'San Bernardo', 'San Cayetano',
    'San Francisco', 'San Juan de Río Seco', 'Sasaima', 'Sesquilé', 'Sibaté',
    'Silvania', 'Simijaca', 'Soacha', 'Sopó', 'Subachoque', 'Suesca',
    'Supatá', 'Susa', 'Sutatausa', 'Tabio', 'Tausa', 'Tena', 'Tenjo',
    'Tibacuy', 'Tibirita', 'Tocaima', 'Tocancipá', 'Topaipí', 'Ubalá',
    'Ubaque', 'Villa de San Diego de Ubate', 'Une', 'Útica', 'Venecia',
    'Vergara', 'Vianí', 'Villagómez', 'Villapinzón', 'Villeta', 'Viotá',
    'Yacopí', 'Zipacón', 'Zipaquirá',
  ];

  final List<String> _tiposDocumento = [
    'Cédula de Ciudadanía', 'Tarjeta de Identidad', 'Cédula de Extranjería',
    'Pasaporte', 'Registro Civil', 'NIT',
  ];

  final List<String> _estadosCiviles = [
    'Soltero/a', 'Casado/a', 'Unión libre', 'Divorciado/a', 'Viudo/a', 'Separado/a',
  ];

  final List<String> _nivelesEducativos = [
    'Ninguno', 'Primaria', 'Secundaria', 'Técnico/Tecnólogo', 'Universitario', 'Posgrado',
  ];

  final List<String> _frecuenciasConsumo = [
    'No consume', 'Ocasional', 'Frecuente', 'Dependiente',
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadAll();
  }

  void _initControllers() {
    _nombreCtrl = TextEditingController();
    _numDocumentoCtrl = TextEditingController();
    _direccionCtrl = TextEditingController();
    _estratoCtrl = TextEditingController();
    _ocupacionCtrl = TextEditingController();
    _institucionCtrl = TextEditingController();
    _identidadOtroCtrl = TextEditingController();
    _epsIpsCtrl = TextEditingController();
    _numEmbarazosCtrl = TextEditingController();
    _numPartosCtrl = TextEditingController();
    _numCesareasCtrl = TextEditingController();
    _numAbortosCtrl = TextEditingController();
    _numHijosCtrl = TextEditingController();
    _redApoyoCtrl = TextEditingController();
    _caidasCtrl = TextEditingController();
    _numParejasActualesCtrl = TextEditingController();
    _numParejasAnioCtrl = TextEditingController();
    for (final ctrl in _allControllers) {
      ctrl.addListener(_saveDraft);
    }
  }

  @override
  void dispose() {
    for (final ctrl in _allControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  // ── Carga inicial ──────────────────────────────────────────────────────────
  Future<void> _loadAll() async {
    final session = await SessionService.getSession();
    if (session == null) {
      if (mounted) setState(() => _isLoading = false);
      _isInitializing = false;
      return;
    }
    _userId = session['userId'];

    bool hasServerData = false;

    // 1. Intentar cargar caracterización existente
    try {
      final data = await ApiService.getCaracterizacion(_userId!);
      if (data.isNotEmpty) {
        _fillFromCaracterizacion(data);
        setState(() => _tieneCaracterizacionExistente = true);
        hasServerData = true;
      }
    } catch (_) {}

    // 2. Pre-rellenar datos del perfil registrado (siempre, solo si el campo está vacío)
    try {
      final perfil = await ApiService.getMiPerfil();
      _prefillFromPerfil(perfil);
    } catch (_) {
      _prefillFromSession(session);
    }

    // 3. Terminar inicialización y mostrar formulario
    _isInitializing = false;
    if (mounted) setState(() => _isLoading = false);

    // 4. Si no hay datos del servidor, verificar borrador (después de renderizar)
    if (!hasServerData && mounted) {
      await Future.microtask(() => null);
      await _checkDraft();
    }
  }

  void _prefillFromPerfil(Map<String, dynamic> perfil) {
    setState(() {
      if (_nombreCtrl.text.isEmpty) {
        _nombreCtrl.text = (perfil['nombre_completo'] as String?) ?? '';
      }
      if (_numDocumentoCtrl.text.isEmpty) {
        _numDocumentoCtrl.text = (perfil['numero_documento'] as String?) ?? '';
      }
      if (_direccionCtrl.text.isEmpty) {
        _direccionCtrl.text = (perfil['direccion'] as String?) ?? '';
      }
      final docTipo = perfil['tipo_documento'] as String?;
      if (tipoDocumentoSeleccionado == null &&
          docTipo != null &&
          docTipo.isNotEmpty &&
          _tiposDocumento.contains(docTipo)) {
        tipoDocumentoSeleccionado = docTipo;
      }
      if (fechaNacimiento == null && perfil['fecha_nacimiento'] != null) {
        fechaNacimiento = DateTime.tryParse(perfil['fecha_nacimiento'] as String);
      }
    });
  }

  void _prefillFromSession(Map<String, dynamic> session) {
    setState(() {
      final nombre = session['nombre'] as String? ?? '';
      if (nombre.isNotEmpty && _nombreCtrl.text.isEmpty) {
        _nombreCtrl.text = nombre;
      }
      final numDoc = session['numeroDocumento'] as String? ?? '';
      if (numDoc.isNotEmpty && _numDocumentoCtrl.text.isEmpty) {
        _numDocumentoCtrl.text = numDoc;
      }
      final dir = session['direccion'] as String? ?? '';
      if (dir.isNotEmpty && _direccionCtrl.text.isEmpty) {
        _direccionCtrl.text = dir;
      }
      final docTipo = session['tipoDocumento'] as String? ?? '';
      if (tipoDocumentoSeleccionado == null &&
          docTipo.isNotEmpty &&
          _tiposDocumento.contains(docTipo)) {
        tipoDocumentoSeleccionado = docTipo;
      }
      final fechaStr = session['fechaNacimiento'] as String? ?? '';
      if (fechaNacimiento == null && fechaStr.isNotEmpty) {
        fechaNacimiento = DateTime.tryParse(fechaStr);
      }
    });
  }

  void _fillFromCaracterizacion(Map<String, dynamic> d) {
    setState(() {
      sexoBiologico = _str(d['sexo_biologico']);
      sexoSeleccionado = _str(d['sexo']);
      mostrarOtroSexo = sexoSeleccionado == 'Otro';
      _haRealizadoCitologia = d['ha_realizado_citologia'] as bool?;
      estadoCivilSeleccionado = _str(d['estado_civil']);
      nivelEducativo = _str(d['nivel_educativo']);
      zonaResidencia = _str(d['zona_residencia']);
      municipioSeleccionado = _str(d['municipio']);
      consumeAlcohol = _str(d['consume_alcohol']);
      consumeTabaco = _str(d['consume_tabaco']);
      _enGestacion = d['en_gestacion'] as bool?;
      _enLactancia = d['en_lactancia'] as bool?;
      _tieneHijos = d['tiene_hijos'] as bool?;
      _vivenSolo = d['vive_solo'] as bool?;
      _dificultadMovilidad = d['dificultad_movilidad'] as bool?;
      _polifarmacia = d['polifarmacia'] as bool?;
      _vidaSexualActiva = d['vida_sexual_activa'] as bool?;
      _metodoProteccion = _str(d['metodo_proteccion']);
      _pruebaEts = d['prueba_ets'] as bool?;
      if (d['fecha_ultima_citologia'] != null) {
        fechaUltimaCitologia = DateTime.tryParse(d['fecha_ultima_citologia'] as String);
      }
    });
    _setCtrl(_estratoCtrl, d['estrato']);
    _setCtrl(_ocupacionCtrl, d['ocupacion']);
    _setCtrl(_institucionCtrl, d['institucion_educativa']);
    _setCtrl(_identidadOtroCtrl, d['identidad_otro']);
    _setCtrl(_epsIpsCtrl, d['eps_ips']);
    _setCtrl(_numEmbarazosCtrl, d['num_embarazos']);
    _setCtrl(_numPartosCtrl, d['num_partos']);
    _setCtrl(_numCesareasCtrl, d['num_cesareas']);
    _setCtrl(_numAbortosCtrl, d['num_abortos']);
    _setCtrl(_numHijosCtrl, d['numero_hijos']);
    _setCtrl(_redApoyoCtrl, d['red_apoyo']);
    _setCtrl(_caidasCtrl, d['caidas_ultimo_anio']);
    _setCtrl(_numParejasActualesCtrl, d['num_parejas_actuales']);
    _setCtrl(_numParejasAnioCtrl, d['num_parejas_ultimo_anio']);
  }

  String? _str(dynamic v) {
    if (v == null || v.toString().isEmpty) return null;
    return v.toString();
  }

  void _setCtrl(TextEditingController ctrl, dynamic value) {
    if (value != null && value.toString().isNotEmpty) {
      ctrl.text = value.toString();
    }
  }

  // ── Borrador ───────────────────────────────────────────────────────────────
  Future<void> _checkDraft() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftKey);
    if (raw == null || raw.isEmpty) return;

    if (!mounted) return;
    final continuar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.save_alt, color: Color(0xFF00A99D)),
          SizedBox(width: 8),
          Flexible(child: Text('Borrador guardado')),
        ]),
        content: const Text('Tienes un borrador guardado. ¿Deseas continuarlo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Empezar de nuevo', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A99D)),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );

    if (continuar == true) {
      await _restoreDraft();
    } else {
      await _clearDraft();
    }
  }

  Future<void> _restoreDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftKey);
    if (raw == null) return;
    try {
      final d = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        sexoBiologico = _str(d['sexoBiologico']);
        sexoSeleccionado = _str(d['sexo']);
        mostrarOtroSexo = sexoSeleccionado == 'Otro';
        _haRealizadoCitologia = d['haRealizadoCitologia'] as bool?;
        tipoDocumentoSeleccionado = _str(d['tipoDocumento']);
        estadoCivilSeleccionado = _str(d['estadoCivil']);
        nivelEducativo = _str(d['nivelEducativo']);
        zonaResidencia = _str(d['zonaResidencia']);
        municipioSeleccionado = _str(d['municipio']);
        consumeAlcohol = _str(d['consumeAlcohol']);
        consumeTabaco = _str(d['consumeTabaco']);
        if (d['fechaNacimiento'] != null) {
          fechaNacimiento = DateTime.tryParse(d['fechaNacimiento'] as String);
        }
        if (d['fechaUltimaCitologia'] != null) {
          fechaUltimaCitologia = DateTime.tryParse(d['fechaUltimaCitologia'] as String);
        }
        _enGestacion = d['enGestacion'] as bool?;
        _enLactancia = d['enLactancia'] as bool?;
        _tieneHijos = d['tieneHijos'] as bool?;
        _vivenSolo = d['vivenSolo'] as bool?;
        _dificultadMovilidad = d['dificultadMovilidad'] as bool?;
        _polifarmacia = d['polifarmacia'] as bool?;
        _vidaSexualActiva = d['vidaSexualActiva'] as bool?;
        _metodoProteccion = _str(d['metodoProteccion']);
        _pruebaEts = d['pruebaEts'] as bool?;
      });
      _setCtrl(_nombreCtrl, d['nombre']);
      _setCtrl(_numDocumentoCtrl, d['numDocumento']);
      _setCtrl(_direccionCtrl, d['direccion']);
      _setCtrl(_estratoCtrl, d['estrato']);
      _setCtrl(_ocupacionCtrl, d['ocupacion']);
      _setCtrl(_institucionCtrl, d['institucion']);
      _setCtrl(_identidadOtroCtrl, d['identidadOtro']);
      _setCtrl(_epsIpsCtrl, d['epsIps']);
      _setCtrl(_numEmbarazosCtrl, d['numEmbarazos']);
      _setCtrl(_numPartosCtrl, d['numPartos']);
      _setCtrl(_numCesareasCtrl, d['numCesareas']);
      _setCtrl(_numAbortosCtrl, d['numAbortos']);
      _setCtrl(_numHijosCtrl, d['numHijos']);
      _setCtrl(_redApoyoCtrl, d['redApoyo']);
      _setCtrl(_caidasCtrl, d['caidas']);
      _setCtrl(_numParejasActualesCtrl, d['numParejasActuales']);
      _setCtrl(_numParejasAnioCtrl, d['numParejasAnio']);
    } catch (_) {}
  }

  Future<void> _saveDraft() async {
    if (_isInitializing || _userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final draft = {
      'nombre': _nombreCtrl.text,
      'numDocumento': _numDocumentoCtrl.text,
      'direccion': _direccionCtrl.text,
      'sexoBiologico': sexoBiologico,
      'sexo': sexoSeleccionado,
      'identidadOtro': _identidadOtroCtrl.text,
      'epsIps': _epsIpsCtrl.text,
      'tipoDocumento': tipoDocumentoSeleccionado,
      'estadoCivil': estadoCivilSeleccionado,
      'estrato': _estratoCtrl.text,
      'ocupacion': _ocupacionCtrl.text,
      'nivelEducativo': nivelEducativo,
      'institucion': _institucionCtrl.text,
      'zonaResidencia': zonaResidencia,
      'municipio': municipioSeleccionado,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'numEmbarazos': _numEmbarazosCtrl.text,
      'numPartos': _numPartosCtrl.text,
      'numCesareas': _numCesareasCtrl.text,
      'numAbortos': _numAbortosCtrl.text,
      'haRealizadoCitologia': _haRealizadoCitologia,
      'fechaUltimaCitologia': fechaUltimaCitologia?.toIso8601String(),
      'enGestacion': _enGestacion,
      'enLactancia': _enLactancia,
      'tieneHijos': _tieneHijos,
      'numHijos': _numHijosCtrl.text,
      'vivenSolo': _vivenSolo,
      'redApoyo': _redApoyoCtrl.text,
      'dificultadMovilidad': _dificultadMovilidad,
      'caidas': _caidasCtrl.text,
      'polifarmacia': _polifarmacia,
      'vidaSexualActiva': _vidaSexualActiva,
      'metodoProteccion': _metodoProteccion,
      'pruebaEts': _pruebaEts,
      'numParejasActuales': _numParejasActualesCtrl.text,
      'numParejasAnio': _numParejasAnioCtrl.text,
      'consumeAlcohol': consumeAlcohol,
      'consumeTabaco': consumeTabaco,
    };
    await prefs.setString(_draftKey, jsonEncode(draft));
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Map<String, dynamic> _buildPayload() {
    final payload = <String, dynamic>{
      'usuario': int.tryParse(_userId ?? ''),
      'sexo_biologico': sexoBiologico ?? '',
      'sexo': sexoSeleccionado ?? '',
      'identidad_otro': _identidadOtroCtrl.text,
      'eps_ips': _epsIpsCtrl.text,
      'estado_civil': estadoCivilSeleccionado ?? '',
      'estrato': _estratoCtrl.text,
      'ocupacion': _ocupacionCtrl.text,
      'nivel_educativo': nivelEducativo ?? '',
      'institucion_educativa': _institucionCtrl.text,
      'zona_residencia': zonaResidencia ?? '',
      'municipio': municipioSeleccionado ?? '',
      'tiene_hijos': _tieneHijos,
      'vive_solo': _vivenSolo,
      'vida_sexual_activa': _esMenor12 ? null : _vidaSexualActiva,
      'num_parejas_actuales': _vidaSexualActiva == true ? int.tryParse(_numParejasActualesCtrl.text) : null,
      'num_parejas_ultimo_anio': _vidaSexualActiva == true ? int.tryParse(_numParejasAnioCtrl.text) : null,
      'metodo_proteccion': _vidaSexualActiva == true ? (_metodoProteccion ?? '') : '',
      'prueba_ets': _vidaSexualActiva == true ? _pruebaEts : null,
      'consume_alcohol': _esMenor18 ? 'N/A' : (consumeAlcohol ?? ''),
      'consume_tabaco': _esMenor18 ? 'N/A' : (consumeTabaco ?? ''),
    };

    if (_mostrarCamposFemeninos) {
      payload['num_embarazos'] = int.tryParse(_numEmbarazosCtrl.text);
      payload['num_partos'] = int.tryParse(_numPartosCtrl.text);
      payload['num_cesareas'] = int.tryParse(_numCesareasCtrl.text);
      payload['num_abortos'] = int.tryParse(_numAbortosCtrl.text);
      payload['ha_realizado_citologia'] = _haRealizadoCitologia;
      payload['fecha_ultima_citologia'] =
          fechaUltimaCitologia?.toIso8601String().split('T').first;
      payload['en_gestacion'] = _enGestacion;
      payload['en_lactancia'] = _enLactancia;
    }

    if (_tieneHijos == true) {
      payload['numero_hijos'] = int.tryParse(_numHijosCtrl.text);
    }

    if (_vivenSolo == true) {
      payload['red_apoyo'] = _redApoyoCtrl.text;
    }

    if (_esMayor60) {
      payload['dificultad_movilidad'] = _dificultadMovilidad;
      payload['caidas_ultimo_anio'] = int.tryParse(_caidasCtrl.text);
      payload['polifarmacia'] = _polifarmacia;
    }

    return payload;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (fechaNacimiento == null) {
      _showErrorDialog('Por favor seleccione su fecha de nacimiento');
      return;
    }
    if (tipoDocumentoSeleccionado == null) {
      _showErrorDialog('Por favor seleccione el tipo de documento');
      return;
    }
    if (municipioSeleccionado == null) {
      _showErrorDialog('Por favor seleccione el municipio');
      return;
    }
    if (sexoBiologico == null) {
      _showErrorDialog('Por favor seleccione el sexo de nacimiento');
      return;
    }
    if (sexoSeleccionado == null) {
      _showErrorDialog('Por favor seleccione la identidad de género');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final payload = _buildPayload();
      if (_tieneCaracterizacionExistente) {
        await ApiService.updateCaracterizacion(_userId!, payload);
      } else {
        await ApiService.saveCaracterizacion(payload);
        setState(() => _tieneCaracterizacionExistente = true);
      }
      await _clearDraft();
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HistorialClinico(sexo: sexoBiologico)),
        );
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00A99D))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Caracterización Sociodemográfica',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00A99D),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── 1. Datos de registro ─────────────────────────────────────────
            _buildCard(
              title: 'Datos de Registro',
              icon: Icons.person,
              child: Column(children: [
                _buildTextField(
                  'Nombre Completo', Icons.badge,
                  controller: _nombreCtrl,
                  validator: validateRequired,
                ),
                const SizedBox(height: 12),
                _buildDatePicker(
                  label: 'Fecha de Nacimiento',
                  icon: Icons.cake,
                  value: fechaNacimiento,
                  onPicked: (d) {
                    setState(() => fechaNacimiento = d);
                    _saveDraft();
                  },
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  'Tipo de Documento',
                  _tiposDocumento,
                  tipoDocumentoSeleccionado,
                  (val) {
                    setState(() => tipoDocumentoSeleccionado = val);
                    _saveDraft();
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Número de Documento', Icons.numbers,
                  controller: _numDocumentoCtrl,
                  keyboardType: TextInputType.number,
                  validator: validateRequired,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'EPS / IPS (entidad de salud)', Icons.local_hospital,
                  controller: _epsIpsCtrl,
                  validator: (_) => null,
                ),
              ]),
            ),

            // ── 2. Sexo biológico e identidad de género ──────────────────────
            _buildCard(
              title: 'Sexo e Identidad de Género',
              icon: Icons.transgender,
              child: Column(children: [
                // 2a. Sexo biológico (discreto, condicional para historial)
                _buildDropdown(
                  '¿Cuál es su sexo de nacimiento?',
                  ['Hombre', 'Mujer'],
                  sexoBiologico,
                  (val) {
                    setState(() {
                      sexoBiologico = val;
                    });
                    _saveDraft();
                  },
                ),
                const SizedBox(height: 12),
                // 2b. Identidad de género
                _buildDropdown(
                  '¿Con qué género se identifica?',
                  ['Hombre', 'Mujer', 'Hombre trans', 'Mujer trans', 'No binario', 'Otro'],
                  sexoSeleccionado,
                  (val) {
                    setState(() {
                      sexoSeleccionado = val;
                      mostrarOtroSexo = val == 'Otro';
                    });
                    _saveDraft();
                  },
                ),
                if (mostrarOtroSexo) ...[
                  const SizedBox(height: 12),
                  _buildTextField(
                    '¿Con cuál identidad se identifica?', Icons.edit,
                    controller: _identidadOtroCtrl,
                    validator: validateRequired,
                  ),
                ],
              ]),
            ),

            // ── 3. Socioeconómica ────────────────────────────────────────────
            _buildCard(
              title: 'Socioeconómica',
              icon: Icons.home_work,
              child: Column(children: [
                _buildDropdown(
                  'Estado Civil', _estadosCiviles, estadoCivilSeleccionado,
                  (val) {
                    setState(() => estadoCivilSeleccionado = val);
                    _saveDraft();
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Estrato Socioeconómico', Icons.attach_money,
                  controller: _estratoCtrl,
                  keyboardType: TextInputType.number,
                  validator: validateNumber,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Ocupación', Icons.work,
                  controller: _ocupacionCtrl,
                  validator: validateRequired,
                ),
              ]),
            ),

            // ── 4. Educación ─────────────────────────────────────────────────
            _buildCard(
              title: 'Educación',
              icon: Icons.school,
              child: Column(children: [
                _buildDropdown(
                  'Nivel Educativo', _nivelesEducativos, nivelEducativo,
                  (val) {
                    setState(() => nivelEducativo = val);
                    _saveDraft();
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Institución Educativa', Icons.account_balance,
                  controller: _institucionCtrl,
                  validator: validateRequired,
                ),
              ]),
            ),

            // ── 5. Ubicación ─────────────────────────────────────────────────
            _buildCard(
              title: 'Ubicación',
              icon: Icons.map,
              child: Column(children: [
                _buildDropdown(
                  'Zona de Residencia', ['Urbana', 'Rural'], zonaResidencia,
                  (val) {
                    setState(() => zonaResidencia = val);
                    _saveDraft();
                  },
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  'Municipio de Cundinamarca', _municipiosCundinamarca,
                  municipioSeleccionado,
                  (val) {
                    setState(() => municipioSeleccionado = val);
                    _saveDraft();
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Dirección', Icons.location_on,
                  controller: _direccionCtrl,
                  validator: (_) => null,
                ),
              ]),
            ),

            // ── 6. Salud Reproductiva (solo si sexo biológico = Mujer) ────────
            if (_mostrarCamposFemeninos)
              _buildCard(
                title: 'Salud Reproductiva',
                icon: Icons.favorite_border,
                child: Column(children: [
                  _buildTextField(
                    'Número de embarazos', Icons.child_friendly,
                    controller: _numEmbarazosCtrl,
                    keyboardType: TextInputType.number,
                    validator: (_) => null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Número de partos', Icons.child_care,
                    controller: _numPartosCtrl,
                    keyboardType: TextInputType.number,
                    validator: (_) => null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Número de cesáreas', Icons.local_hospital,
                    controller: _numCesareasCtrl,
                    keyboardType: TextInputType.number,
                    validator: (_) => null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Número de abortos', Icons.healing,
                    controller: _numAbortosCtrl,
                    keyboardType: TextInputType.number,
                    validator: (_) => null,
                  ),
                  const SizedBox(height: 12),
                  // Citología — punto 10
                  _buildYesNo(
                    '¿Se ha realizado citología?',
                    _haRealizadoCitologia,
                    (val) {
                      setState(() {
                        _haRealizadoCitologia = val;
                        if (val == false) fechaUltimaCitologia = null;
                      });
                      _saveDraft();
                    },
                  ),
                  if (_haRealizadoCitologia == true) ...[
                    const SizedBox(height: 12),
                    _buildDatePicker(
                      label: 'Fecha del último resultado de citología',
                      icon: Icons.calendar_today,
                      value: fechaUltimaCitologia,
                      firstDate: DateTime(1990),
                      required: false,
                      onPicked: (d) {
                        setState(() => fechaUltimaCitologia = d);
                        _saveDraft();
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildYesNo(
                    '¿Está en gestación actualmente?',
                    _enGestacion,
                    (val) {
                      setState(() => _enGestacion = val);
                      _saveDraft();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildYesNo(
                    '¿Está en período de lactancia?',
                    _enLactancia,
                    (val) {
                      setState(() => _enLactancia = val);
                      _saveDraft();
                    },
                  ),
                ]),
              ),

            // ── 7. Familia ───────────────────────────────────────────────────
            _buildCard(
              title: 'Familia',
              icon: Icons.family_restroom,
              child: Column(children: [
                _buildYesNo(
                  '¿Tiene hijos?',
                  _tieneHijos,
                  (val) {
                    setState(() => _tieneHijos = val);
                    _saveDraft();
                  },
                ),
                if (_tieneHijos == true) ...[
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Número de hijos', Icons.group,
                    controller: _numHijosCtrl,
                    keyboardType: TextInputType.number,
                    validator: validateNumber,
                  ),
                ],
              ]),
            ),

            // ── 8. Convivencia ───────────────────────────────────────────────
            _buildCard(
              title: 'Convivencia',
              icon: Icons.home,
              child: Column(children: [
                _buildYesNo(
                  '¿Vive solo/a?',
                  _vivenSolo,
                  (val) {
                    setState(() => _vivenSolo = val);
                    _saveDraft();
                  },
                ),
                if (_vivenSolo == true) ...[
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Red de apoyo (familiar, vecino, institución...)',
                    Icons.people,
                    controller: _redApoyoCtrl,
                    validator: validateRequired,
                  ),
                ],
              ]),
            ),

            // ── 9. Adulto mayor (solo si edad ≥ 60) ─────────────────────────
            if (_esMayor60)
              _buildCard(
                title: 'Adulto Mayor',
                icon: Icons.elderly,
                child: Column(children: [
                  _buildYesNo(
                    '¿Presenta dificultad de movilidad?',
                    _dificultadMovilidad,
                    (val) {
                      setState(() => _dificultadMovilidad = val);
                      _saveDraft();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Caídas en el último año', Icons.transfer_within_a_station,
                    controller: _caidasCtrl,
                    keyboardType: TextInputType.number,
                    validator: (_) => null,
                  ),
                  const SizedBox(height: 12),
                  _buildYesNo(
                    '¿Polifarmacia? (consume 5 o más medicamentos)',
                    _polifarmacia,
                    (val) {
                      setState(() => _polifarmacia = val);
                      _saveDraft();
                    },
                  ),
                ]),
              ),

            // ── 10. Estilos de vida ──────────────────────────────────────────
            _buildCard(
              title: 'Estilos de Vida',
              icon: Icons.health_and_safety,
              child: Column(children: [
                if (!_esMenor12) ...[
                  _buildYesNo(
                    '¿Tiene vida sexual activa?',
                    _vidaSexualActiva,
                    (val) {
                      setState(() {
                        _vidaSexualActiva = val;
                        if (val == false) {
                          _numParejasActualesCtrl.clear();
                          _numParejasAnioCtrl.clear();
                          _metodoProteccion = null;
                          _pruebaEts = null;
                        }
                      });
                      _saveDraft();
                    },
                  ),
                  if (_vidaSexualActiva == true) ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      '¿Con cuántas parejas tiene relaciones actualmente?',
                      Icons.people_outline,
                      controller: _numParejasActualesCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Número de parejas en el último año',
                      Icons.history,
                      controller: _numParejasAnioCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      '¿Usa método de protección?',
                      ['Siempre', 'A veces', 'Nunca'],
                      _metodoProteccion,
                      (val) {
                        setState(() => _metodoProteccion = val);
                        _saveDraft();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildYesNo(
                      '¿Se ha realizado prueba de ETS?',
                      _pruebaEts,
                      (val) {
                        setState(() => _pruebaEts = val);
                        _saveDraft();
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
                if (_esMenor18)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: const Row(children: [
                      Icon(Icons.info_outline, color: Colors.amber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Consumo de alcohol y tabaco no aplica para menores de 18 años.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ]),
                  )
                else ...[
                  _buildDropdown(
                    'Consumo de alcohol', _frecuenciasConsumo, consumeAlcohol,
                    (val) {
                      setState(() => consumeAlcohol = val);
                      _saveDraft();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    'Consumo de tabaco', _frecuenciasConsumo, consumeTabaco,
                    (val) {
                      setState(() => consumeTabaco = val);
                      _saveDraft();
                    },
                  ),
                ],
              ]),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A99D),
                minimumSize: const Size.fromHeight(55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'CONTINUAR CON HISTORIAL CLÍNICO',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Widget helpers ─────────────────────────────────────────────────────────
  Widget _buildYesNo(String question, bool? value, void Function(bool?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Sí'),
                value: true,
                groupValue: value,
                activeColor: const Color(0xFF00A99D),
                contentPadding: EdgeInsets.zero,
                dense: true,
                onChanged: (val) => setState(() => onChanged(val)),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('No'),
                value: false,
                groupValue: value,
                activeColor: const Color(0xFF00A99D),
                contentPadding: EdgeInsets.zero,
                dense: true,
                onChanged: (val) => setState(() => onChanged(val)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Icon(icon, color: const Color(0xFF00A99D)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00A99D),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF00A99D)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    IconData icon, {
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      validator: validator ?? (_) => null,
    );
  }

  Widget _buildReadOnlyField(
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: const Tooltip(
          message: 'Dato del registro',
          child: Icon(Icons.lock_outline, size: 16, color: Colors.grey),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    List<String> items,
    String? value,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.arrow_drop_down_circle),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Selecciona una opción' : null,
    );
  }

  Widget _buildDropdownOpcional(
    String hint,
    List<String> items,
    String? value,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.arrow_drop_down_circle),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (_) => null,
    );
  }

  Widget _buildDatePicker({
    required String label,
    required IconData icon,
    required DateTime? value,
    required void Function(DateTime) onPicked,
    DateTime? firstDate,
    bool required = true,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(2000),
          firstDate: firstDate ?? DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(30))),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          value == null
              ? required
                  ? 'Seleccione una fecha *'
                  : 'Seleccione una fecha (opcional)'
              : '${value.day}/${value.month}/${value.year}',
          style: TextStyle(color: value == null ? Colors.grey : Colors.black),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: 8),
          Text('Error'),
        ]),
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
