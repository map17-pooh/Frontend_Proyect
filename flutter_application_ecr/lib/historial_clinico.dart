import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/custom_widgets.dart';
import 'services/api_service.dart';
import 'services/session_service.dart';

class HistorialClinico extends StatefulWidget {
  final String? sexo;
  const HistorialClinico({super.key, this.sexo});

  @override
  State<HistorialClinico> createState() => _HistorialClinicoState();
}

class _HistorialClinicoState extends State<HistorialClinico> {
  final _formKey = GlobalKey<FormState>();

  bool get _mostrarCamposReproductivos =>
      widget.sexo == null || widget.sexo == 'Mujer';

  bool _isLoading = false;
  bool _isInitializing = true;
  String? _userId;
  bool _tieneHistorialExistente = false;
  String? _haRealizadoCitologiaHC;

  String get _draftKey => 'draft_historial_${_userId ?? 'anon'}';

  final _edadInicioCtrl = TextEditingController();
  final _numeroParejasCtr = TextEditingController();
  final _cantidadHijosCtrl = TextEditingController();
  final _fechaCitologiaController = TextEditingController();
  final _gestacionesCtrl = TextEditingController();
  final _partosCtrl = TextEditingController();
  final _cesareasCtrl = TextEditingController();
  final _abortosCtrl = TextEditingController();
  final _ectopicosCtrl = TextEditingController();
  final _hijosVivosCtrl = TextEditingController();
  final _hijosMuertosCtrl = TextEditingController();
  final _metodoUsadoCtrl = TextEditingController();
  final _experienciaObsCtrl = TextEditingController();
  final _metodoActualCtrl = TextEditingController();
  final _tiempoMetodoCtrl = TextEditingController();
  final _otroTemaCtrl = TextEditingController();
  final _otraEnfermedadCtrl = TextEditingController();
  final _tiempoMetodoParejaCtrl = TextEditingController();

  List<TextEditingController> get _allControllers => [
    _edadInicioCtrl, _numeroParejasCtr, _cantidadHijosCtrl,
    _fechaCitologiaController, _gestacionesCtrl, _partosCtrl,
    _cesareasCtrl, _abortosCtrl, _ectopicosCtrl, _hijosVivosCtrl,
    _hijosMuertosCtrl, _metodoUsadoCtrl, _experienciaObsCtrl,
    _metodoActualCtrl, _tiempoMetodoCtrl, _otroTemaCtrl, _otraEnfermedadCtrl,
    _tiempoMetodoParejaCtrl,
  ];

  @override
  void initState() {
    super.initState();
    for (final c in _allControllers) {
      c.addListener(_saveDraft);
    }
    _loadHistorial();
  }

  @override
  void dispose() {
    for (final c in _allControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadHistorial() async {
    final session = await SessionService.getSession();
    _userId = session?['userId'];
    if (_userId == null) {
      if (mounted) setState(() => _isInitializing = false);
      return;
    }

    try {
      final data = await ApiService.getHistorialClinico(_userId!);
      if (data.isNotEmpty) {
        if (mounted) {
          setState(() {
            _tieneHistorialExistente = true;
            _fillFromHistorial(data);
            _isInitializing = false;
          });
        }
        return;
      }
    } catch (_) {}

    await _checkDraft();
    if (mounted) setState(() => _isInitializing = false);
  }

  Future<void> _checkDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftKey);
    if (raw == null || raw.isEmpty) return;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    if (mounted) {
      setState(() => _restoreDraft(data));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Borrador restaurado'),
          backgroundColor: Color(0xFF00A99D),
        ),
      );
    }
  }

  Future<void> _saveDraft() async {
    if (_isInitializing) return;
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'inicio_vida_sexual': inicioVidaSexual,
      'edad_inicio_vida_sexual': _edadInicioCtrl.text,
      'tiene_pareja': tienePareja,
      'pareja_sexual': parejaSexual,
      'numero_parejas': _numeroParejasCtr.text,
      'desea_tener_hijos': deseaTenerHijos,
      'tiene_hijos': tieneHijos,
      'cantidad_hijos': _cantidadHijosCtrl.text,
      'ha_realizado_citologia': _haRealizadoCitologiaHC,
      'fecha_citologia': _fechaCitologiaController.text,
      'citologia_tipo': citologiaTipo,
      'gestaciones': _gestacionesCtrl.text,
      'partos': _partosCtrl.text,
      'cesareas': _cesareasCtrl.text,
      'abortos': _abortosCtrl.text,
      'ectopicos': _ectopicosCtrl.text,
      'hijos_nacidos_vivos': _hijosVivosCtrl.text,
      'hijos_nacidos_muertos': _hijosMuertosCtrl.text,
      'ha_usado_metodo': haUsadoMetodo,
      'metodo_usado': _metodoUsadoCtrl.text,
      'experiencia_metodo': experienciaMetodo,
      'experiencia_observacion': _experienciaObsCtrl.text,
      'metodos_utilizados': metodosUtilizados,
      'usa_metodo_actual': usaMetodoActual,
      'metodo_actual': _metodoActualCtrl.text,
      'tiempo_metodo_actual': _tiempoMetodoCtrl.text,
      'tiempo_metodo_pareja': _tiempoMetodoParejaCtrl.text,
      'necesidades_orientacion': necesidadesOrientacion,
      'otro_tema_orientacion': _otroTemaCtrl.text,
      'antecedentes_personales': antecedentesPersonales,
      'otra_enfermedad': _otraEnfermedadCtrl.text,
    };
    await prefs.setString(_draftKey, jsonEncode(data));
  }

  void _restoreDraft(Map<String, dynamic> data) {
    String str(String key) => (data[key] as String?) ?? '';
    String? opt(String key) {
      final v = data[key] as String?;
      return (v != null && v.isNotEmpty) ? v : null;
    }

    inicioVidaSexual = opt('inicio_vida_sexual');
    edadInicioVidaSexual = str('edad_inicio_vida_sexual');
    _edadInicioCtrl.text = edadInicioVidaSexual ?? '';
    tienePareja = opt('tiene_pareja');
    parejaSexual = opt('pareja_sexual');
    numeroParejas = str('numero_parejas');
    _numeroParejasCtr.text = numeroParejas ?? '';
    deseaTenerHijos = opt('desea_tener_hijos');
    tieneHijos = opt('tiene_hijos');
    cantidadHijos = str('cantidad_hijos');
    _cantidadHijosCtrl.text = cantidadHijos ?? '';
    _haRealizadoCitologiaHC = opt('ha_realizado_citologia');
    fechaCitologia = str('fecha_citologia');
    _fechaCitologiaController.text = fechaCitologia ?? '';
    citologiaTipo = List<String>.from(data['citologia_tipo'] ?? []);
    gestaciones = str('gestaciones');
    _gestacionesCtrl.text = gestaciones ?? '';
    partos = str('partos');
    _partosCtrl.text = partos ?? '';
    cesareas = str('cesareas');
    _cesareasCtrl.text = cesareas ?? '';
    abortos = str('abortos');
    _abortosCtrl.text = abortos ?? '';
    ectopicos = str('ectopicos');
    _ectopicosCtrl.text = ectopicos ?? '';
    hijosNacidosVivos = str('hijos_nacidos_vivos');
    _hijosVivosCtrl.text = hijosNacidosVivos ?? '';
    hijosNacidosMuertos = str('hijos_nacidos_muertos');
    _hijosMuertosCtrl.text = hijosNacidosMuertos ?? '';
    haUsadoMetodo = opt('ha_usado_metodo');
    metodoUsado = str('metodo_usado');
    _metodoUsadoCtrl.text = metodoUsado ?? '';
    experienciaMetodo = opt('experiencia_metodo');
    experienciaObservacion = str('experiencia_observacion');
    _experienciaObsCtrl.text = experienciaObservacion ?? '';
    metodosUtilizados = List<String>.from(data['metodos_utilizados'] ?? []);
    usaMetodoActual = opt('usa_metodo_actual');
    metodoActual = str('metodo_actual');
    _metodoActualCtrl.text = metodoActual ?? '';
    tiempoMetodoActual = str('tiempo_metodo_actual');
    _tiempoMetodoCtrl.text = tiempoMetodoActual ?? '';
    tiempoMetodoPareja = str('tiempo_metodo_pareja');
    _tiempoMetodoParejaCtrl.text = tiempoMetodoPareja ?? '';
    necesidadesOrientacion = List<String>.from(data['necesidades_orientacion'] ?? []);
    otroTemaOrientacion = str('otro_tema_orientacion');
    _otroTemaCtrl.text = otroTemaOrientacion ?? '';
    final antData = data['antecedentes_personales'];
    if (antData is Map) {
      for (final key in antecedentesPersonales.keys) {
        antecedentesPersonales[key] = (antData[key] as bool?) ?? false;
      }
    }
    otraEnfermedad = str('otra_enfermedad');
    _otraEnfermedadCtrl.text = otraEnfermedad ?? '';
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  void _fillFromHistorial(Map<String, dynamic> data) {
    String str(String key) => (data[key] as String?) ?? '';
    String? radio(String key) {
      final v = data[key] as String?;
      return (v != null && v.isNotEmpty) ? v : null;
    }

    inicioVidaSexual = radio('inicio_vida_sexual');
    edadInicioVidaSexual = str('edad_inicio_vida_sexual');
    _edadInicioCtrl.text = edadInicioVidaSexual ?? '';
    tienePareja = radio('tiene_pareja');
    parejaSexual = radio('pareja_sexual');
    numeroParejas = str('numero_parejas');
    _numeroParejasCtr.text = numeroParejas ?? '';
    deseaTenerHijos = radio('desea_tener_hijos');
    tieneHijos = radio('tiene_hijos');
    cantidadHijos = str('cantidad_hijos');
    _cantidadHijosCtrl.text = cantidadHijos ?? '';
    fechaCitologia = str('fecha_citologia');
    _haRealizadoCitologiaHC = (fechaCitologia?.isNotEmpty ?? false) ? 'Sí' : null;
    _fechaCitologiaController.text = fechaCitologia ?? '';
    citologiaTipo = List<String>.from(data['citologia_tipo'] ?? []);
    gestaciones = str('gestaciones');
    _gestacionesCtrl.text = gestaciones ?? '';
    partos = str('partos');
    _partosCtrl.text = partos ?? '';
    cesareas = str('cesareas');
    _cesareasCtrl.text = cesareas ?? '';
    abortos = str('abortos');
    _abortosCtrl.text = abortos ?? '';
    ectopicos = str('ectopicos');
    _ectopicosCtrl.text = ectopicos ?? '';
    hijosNacidosVivos = str('hijos_nacidos_vivos');
    _hijosVivosCtrl.text = hijosNacidosVivos ?? '';
    hijosNacidosMuertos = str('hijos_nacidos_muertos');
    _hijosMuertosCtrl.text = hijosNacidosMuertos ?? '';
    haUsadoMetodo = radio('ha_usado_metodo');
    metodoUsado = str('metodo_usado');
    _metodoUsadoCtrl.text = metodoUsado ?? '';
    experienciaMetodo = radio('experiencia_metodo');
    experienciaObservacion = str('experiencia_observacion');
    _experienciaObsCtrl.text = experienciaObservacion ?? '';
    metodosUtilizados = List<String>.from(data['metodos_utilizados'] ?? []);
    usaMetodoActual = radio('usa_metodo_actual');
    metodoActual = str('metodo_actual');
    _metodoActualCtrl.text = metodoActual ?? '';
    tiempoMetodoActual = str('tiempo_metodo_actual');
    _tiempoMetodoCtrl.text = tiempoMetodoActual ?? '';
    tiempoMetodoPareja = str('tiempo_metodo_pareja');
    _tiempoMetodoParejaCtrl.text = tiempoMetodoPareja ?? '';
    necesidadesOrientacion = List<String>.from(data['necesidades_orientacion'] ?? []);
    otroTemaOrientacion = str('otro_tema_orientacion');
    _otroTemaCtrl.text = otroTemaOrientacion ?? '';
    final antData = data['antecedentes_personales'];
    if (antData is Map) {
      for (final key in antecedentesPersonales.keys) {
        antecedentesPersonales[key] = (antData[key] as bool?) ?? false;
      }
    }
    otraEnfermedad = str('otra_enfermedad');
    _otraEnfermedadCtrl.text = otraEnfermedad ?? '';
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'usuario': int.parse(_userId!),
      'inicio_vida_sexual': inicioVidaSexual ?? '',
      'edad_inicio_vida_sexual': edadInicioVidaSexual ?? '',
      'tiene_pareja': tienePareja ?? '',
      'pareja_sexual': parejaSexual ?? '',
      'numero_parejas': numeroParejas ?? '',
      'desea_tener_hijos': deseaTenerHijos ?? '',
      'tiene_hijos': tieneHijos ?? '',
      'cantidad_hijos': cantidadHijos ?? '',
      'fecha_citologia': _haRealizadoCitologiaHC == 'No' ? '' : (fechaCitologia ?? ''),
      'citologia_tipo': citologiaTipo,
      'gestaciones': gestaciones ?? '',
      'partos': partos ?? '',
      'cesareas': cesareas ?? '',
      'abortos': abortos ?? '',
      'ectopicos': ectopicos ?? '',
      'hijos_nacidos_vivos': hijosNacidosVivos ?? '',
      'hijos_nacidos_muertos': hijosNacidosMuertos ?? '',
      'ha_usado_metodo': haUsadoMetodo ?? '',
      'metodo_usado': metodoUsado ?? '',
      'experiencia_metodo': experienciaMetodo ?? '',
      'experiencia_observacion': experienciaObservacion ?? '',
      'metodos_utilizados': metodosUtilizados,
      'usa_metodo_actual': usaMetodoActual ?? '',
      'metodo_actual': metodoActual ?? '',
      'tiempo_metodo_actual': tiempoMetodoActual ?? '',
      'tiempo_metodo_pareja': tiempoMetodoPareja ?? '',
      'necesidades_orientacion': necesidadesOrientacion,
      'otro_tema_orientacion': otroTemaOrientacion ?? '',
      'antecedentes_personales': antecedentesPersonales,
      'otra_enfermedad': otraEnfermedad ?? '',
    };
  }

  Future<void> _saveHistorial() async {
    if (_userId == null) return;
    setState(() => _isLoading = true);
    try {
      final payload = _buildPayload();
      if (_tieneHistorialExistente) {
        await ApiService.updateHistorialClinico(_userId!, payload);
      } else {
        await ApiService.saveHistorialClinico(payload);
        _tieneHistorialExistente = true;
      }
      await _clearDraft();
      if (mounted) _showSuccessDialog();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar. Intenta de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Form state variables ────────────────────────────────────────────────────
  String? inicioVidaSexual;
  String? edadInicioVidaSexual;
  String? tienePareja;
  String? parejaSexual;
  String? numeroParejas;
  String? deseaTenerHijos;
  String? tieneHijos;
  String? cantidadHijos;
  String? fechaCitologia;
  List<String> citologiaTipo = [];
  String? gestaciones;
  String? partos;
  String? cesareas;
  String? abortos;
  String? ectopicos;
  String? hijosNacidosVivos;
  String? hijosNacidosMuertos;

  String? haUsadoMetodo;
  String? metodoUsado;
  String? experienciaMetodo;
  String? experienciaObservacion;
  List<String> metodosUtilizados = [];
  String? usaMetodoActual;
  String? metodoActual;
  String? tiempoMetodoActual;
  String? tiempoMetodoPareja;

  final List<String> metodosAnticonceptivosMujer = [
    'Condón femenino',
    'Condón masculino',
    'Píldora anticonceptiva',
    'Inyección hormonal',
    'DIU (Dispositivo Intrauterino / T de cobre)',
    'Implante subdérmico',
    'Parche anticonceptivo',
    'Anillo vaginal',
    'Ligadura de trompas',
    'Anticoncepción de emergencia (pastilla del día después)',
    'Otro',
  ];

  final List<String> metodosAnticonceptivosHombre = [
    'Condón masculino',
    'Vasectomía',
    'Retiro (coito interruptus)',
    'Anticoncepción de emergencia (pastilla del día después)',
    'Otro',
  ];

  List<String> necesidadesOrientacion = [];
  String? otroTemaOrientacion;

  final List<String> opcionesOrientacion = [
    'Higiene íntima',
    'Derechos sexuales y reproductivos',
    'Métodos anticonceptivos',
    'Doble Protección',
    'Prevención de ITS',
    'Deseo de cambio de método de anticoncepción',
    'IVE (interrupción voluntaria del embarazo)',
  ];

  Map<String, bool> antecedentesPersonales = {
    'Convulsiones o ataques': false,
    'Dolores de cabeza muy fuertes': false,
    'Enfermedad del corazón': false,
    'Problemas en el hígado': false,
    'Problemas en los riñones': false,
    'Presión alta no controlada': false,
    'Presión alta controlada': false,
    'Derrame cerebral': false,
    'Coágulos en las piernas': false,
    'Problemas en la sangre': false,
    'Diabetes': false,
    'Cáncer en los senos': false,
    'Cáncer en la matriz': false,
    'Sangrado vaginal sin causa (Hemorragias)': false,
    'Masas en la matriz': false,
    'Infección en la matriz': false,
    'Infecciones de transmisión sexual': false,
    'VPH (Virus del Papiloma Humano)': false,
    'Condilomatosis (verrugas genitales)': false,
    'Sobrepeso u obesidad': false,
    'Fumas cigarrillo': false,
    'Tomas medicamentos especiales para tuberculosis, VIH o convulsiones': false,
    'Vives con VIH/SIDA': false,
    'Ahora estás dando sólo leche materna a tú bebé': false,
    'Anemia': false,
    'Aborto reciente': false,
    'Infección después de parto o aborto': false,
    'Tuviste bebé reciente y no das leche materna': false,
    'Tienes Lupus': false,
  };
  String? otraEnfermedad;

  // ── Build ───────────────────────────────────────────────────────────────────
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
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 2. Caracterización Sexual y Reproductiva
            _buildSectionCard(
              title: 'Caracterización Sexual y Reproductiva',
              icon: Icons.favorite,
              children: [
                _buildRadioGroup(
                  label: 'Inicio de vida sexual',
                  value: inicioVidaSexual,
                  options: const ['Sí', 'No'],
                  onChanged: (val) {
                    inicioVidaSexual = val;
                    if (val == 'No') edadInicioVidaSexual = '';
                  },
                ),
                if (inicioVidaSexual == 'Sí') ...[
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Edad de inicio de vida sexual',
                    hint: 'Ingrese la edad',
                    icon: Icons.cake,
                    controller: _edadInicioCtrl,
                    onChanged: (val) => edadInicioVidaSexual = val,
                    keyboardType: TextInputType.number,
                    validator: validateNumber,
                  ),
                ],
                const SizedBox(height: 12),
                _buildRadioGroup(
                  label: 'Tiene pareja actualmente',
                  value: tienePareja,
                  options: const ['Sí', 'No'],
                  onChanged: (val) => tienePareja = val,
                ),
                if (tienePareja == 'Sí') ...[
                  const SizedBox(height: 12),
                  _buildRadioGroup(
                    label: 'Su pareja sexual es',
                    value: parejaSexual,
                    options: const ['Hombre', 'Mujer','Hombre trans','Mujer trans'],
                    onChanged: (val) => parejaSexual = val,
                  ),
                ],
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Número de parejas sexuales',
                  hint: 'Cantidad',
                  icon: Icons.people,
                  controller: _numeroParejasCtr,
                  onChanged: (val) => numeroParejas = val,
                  keyboardType: TextInputType.number,
                  validator: validateNumber,
                ),
                const SizedBox(height: 12),
                _buildRadioGroup(
                  label: 'Desea tener hijos',
                  value: deseaTenerHijos,
                  options: const ['Sí', 'No', 'No sabe'],
                  onChanged: (val) => deseaTenerHijos = val,
                ),
                const SizedBox(height: 12),
                _buildRadioGroup(
                  label: '¿Tiene hijos?',
                  value: tieneHijos,
                  options: const ['Sí', 'No'],
                  onChanged: (val) => tieneHijos = val,
                ),
                if (tieneHijos == 'Sí') ...[
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Si tiene hijos, ¿cuántos tiene?',
                    hint: 'Número de hijos',
                    icon: Icons.family_restroom,
                    controller: _cantidadHijosCtrl,
                    onChanged: (val) => cantidadHijos = val,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || value.isEmpty ? null : validateNumber(value),
                  ),
                ],
                const SizedBox(height: 12),
                _buildRadioGroup(
                  label: '¿Se ha realizado alguna vez una citología?',
                  value: _haRealizadoCitologiaHC,
                  options: const ['Sí', 'No'],
                  onChanged: (val) {
                    _haRealizadoCitologiaHC = val;
                    if (val == 'No') {
                      fechaCitologia = '';
                      _fechaCitologiaController.clear();
                    }
                  },
                ),
                if (_haRealizadoCitologiaHC == 'Sí') ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    readOnly: true,
                    controller: _fechaCitologiaController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de última citología',
                      prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF00A99D)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _fechaCitologiaController.text =
                              '${picked.day.toString().padLeft(2, '0')}/'
                              '${picked.month.toString().padLeft(2, '0')}/'
                              '${picked.year}';
                          fechaCitologia = _fechaCitologiaController.text;
                        });
                        _saveDraft();
                      }
                    },
                  ),
                ],
                if (_mostrarCamposReproductivos) ...[
                  const SizedBox(height: 12),
                  _buildCheckboxGroup(
                    label: 'Tipo de citología',
                    options: const ['Vaginal', 'Rectal', 'VPH'],
                    selectedValues: citologiaTipo,
                    onChangedMulti: (val) {
                      citologiaTipo.contains(val)
                          ? citologiaTipo.remove(val)
                          : citologiaTipo.add(val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Gestaciones',
                          hint: 'Número',
                          icon: Icons.pregnant_woman,
                          controller: _gestacionesCtrl,
                          onChanged: (val) => gestaciones = val,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'Partos',
                          hint: 'Número',
                          icon: Icons.child_care,
                          controller: _partosCtrl,
                          onChanged: (val) => partos = val,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Cesáreas',
                          hint: 'Número',
                          icon: Icons.medical_services,
                          controller: _cesareasCtrl,
                          onChanged: (val) => cesareas = val,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'Abortos',
                          hint: 'Número',
                          icon: Icons.warning,
                          controller: _abortosCtrl,
                          onChanged: (val) => abortos = val,
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value == null || value.isEmpty ? null : validateNumber(value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Ectópicos',
                          hint: 'Número',
                          icon: Icons.health_and_safety,
                          controller: _ectopicosCtrl,
                          onChanged: (val) => ectopicos = val,
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value == null || value.isEmpty ? null : validateNumber(value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'Hijos nacidos vivos',
                          hint: 'Número',
                          icon: Icons.favorite,
                          controller: _hijosVivosCtrl,
                          onChanged: (val) => hijosNacidosVivos = val,
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value == null || value.isEmpty ? null : validateNumber(value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Hijos nacidos muertos',
                    hint: 'Número',
                    icon: Icons.sentiment_dissatisfied,
                    controller: _hijosMuertosCtrl,
                    onChanged: (val) => hijosNacidosMuertos = val,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || value.isEmpty ? null : validateNumber(value),
                  ),
                ],
              ],
            ),

            // 3. Antecedentes en anticoncepción
            _buildSectionCard(
              title: 'Antecedentes en Anticoncepción',
              icon: Icons.medical_services,
              children: [
                if (_mostrarCamposReproductivos) ...[
                  _buildRadioGroup(
                    label: '¿Ha utilizado algún método anticonceptivo?',
                    value: haUsadoMetodo,
                    options: const ['Sí', 'No'],
                    onChanged: (val) => haUsadoMetodo = val,
                  ),
                  if (haUsadoMetodo == 'Sí') ...[
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      label: '¿Cuál método ha utilizado?',
                      items: metodosAnticonceptivosMujer,
                      value: metodoUsado?.isEmpty ?? true ? null : metodoUsado,
                      onChanged: (val) {
                        metodoUsado = val;
                        _metodoUsadoCtrl.text = val ?? '';
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildRadioGroup(
                      label: '¿Cómo ha sido su experiencia?',
                      value: experienciaMetodo,
                      options: const ['Satisfactoria', 'No satisfactoria'],
                      onChanged: (val) => experienciaMetodo = val,
                    ),
                    if (experienciaMetodo == 'No satisfactoria') ...[
                      const SizedBox(height: 12),
                      _buildTextField(
                        label: '¿Por qué no fue satisfactoria?',
                        hint: 'Describa el motivo',
                        icon: Icons.comment,
                        controller: _experienciaObsCtrl,
                        onChanged: (val) => experienciaObservacion = val,
                        validator: validateRequired,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildCheckboxGroup(
                      label: 'Otros métodos que ha utilizado (puede marcar varios)',
                      options: metodosAnticonceptivosMujer,
                      selectedValues: metodosUtilizados,
                      onChangedMulti: (val) {
                        metodosUtilizados.contains(val)
                            ? metodosUtilizados.remove(val)
                            : metodosUtilizados.add(val);
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildRadioGroup(
                    label: '¿Actualmente usa método anticonceptivo?',
                    value: usaMetodoActual,
                    options: const ['Sí', 'No'],
                    onChanged: (val) => usaMetodoActual = val,
                  ),
                  if (usaMetodoActual == 'Sí') ...[
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      label: '¿Cuál método utiliza actualmente?',
                      items: metodosAnticonceptivosMujer,
                      value: metodoActual?.isEmpty ?? true ? null : metodoActual,
                      onChanged: (val) {
                        metodoActual = val;
                        _metodoActualCtrl.text = val ?? '';
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: '¿Hace cuánto tiempo usa este método?',
                      hint: 'Ej: 6 meses, 2 años',
                      icon: Icons.timer,
                      controller: _tiempoMetodoCtrl,
                      onChanged: (val) => tiempoMetodoActual = val,
                    ),
                  ],
                ],

                if (!_mostrarCamposReproductivos) ...[
                  _buildRadioGroup(
                    label: '¿Usa condón actualmente?',
                    value: usaMetodoActual,
                    options: const ['Sí', 'No'],
                    onChanged: (val) => usaMetodoActual = val,
                  ),
                  if (usaMetodoActual == 'Sí') ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: '¿Hace cuánto tiempo usa este método?',
                      hint: 'Ej: 6 meses, 2 años',
                      icon: Icons.timer,
                      controller: _tiempoMetodoCtrl,
                      onChanged: (val) => tiempoMetodoActual = val,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: '¿Qué método anticonceptivo está utilizando su pareja actualmente?',
                    items: const [
                      'Ninguno',
                      'Píldora anticonceptiva',
                      'Inyección hormonal',
                      'DIU (Dispositivo Intrauterino)',
                      'Implante subdérmico',
                      'Parche anticonceptivo',
                      'Ligadura de trompas',
                      'No sabe',
                    ],
                    value: metodoUsado?.isEmpty ?? true ? null : metodoUsado,
                    onChanged: (val) {
                      metodoUsado = val;
                      _metodoUsadoCtrl.text = val ?? '';
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: '¿Hace cuánto tiempo usa este método su pareja?',
                    hint: 'Ej: 6 meses, 2 años',
                    icon: Icons.timer,
                    controller: _tiempoMetodoParejaCtrl,
                    onChanged: (val) => tiempoMetodoPareja = val,
                  ),
                ],
              ],
            ),

            // 4. Necesidad de Orientación
            _buildSectionCard(
              title: 'Necesidad de Orientación',
              icon: Icons.psychology,
              children: [
                _buildCheckboxGroup(
                  label: 'Desea recibir orientación en: (señale con X)',
                  options: opcionesOrientacion,
                  selectedValues: necesidadesOrientacion,
                  onChangedMulti: (val) {
                    if (necesidadesOrientacion.contains(val)) {
                      necesidadesOrientacion.remove(val);
                    } else {
                      necesidadesOrientacion.add(val);
                    }
                  },
                ),
                if (necesidadesOrientacion.contains('Otro tema en sexualidad, cuál?')) ...[
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Otro tema en sexualidad',
                    hint: 'Especifique',
                    icon: Icons.edit,
                    controller: _otroTemaCtrl,
                    onChanged: (val) => otroTemaOrientacion = val,
                  ),
                ],
              ],
            ),

            // 5. Antecedentes personales (Criterios OMS)
            _buildSectionCard(
              title: 'Antecedentes Personales (Criterios de Elegibilidad OMS)',
              icon: Icons.assignment_ind,
              subtitle: 'Señale con X según sea su situación',
              children: [
                ...antecedentesPersonales.keys.map((key) {
                  return _buildCheckbox(
                    label: key,
                    value: antecedentesPersonales[key] ?? false,
                    onChanged: (val) {
                      setState(() => antecedentesPersonales[key] = val ?? false);
                      _saveDraft();
                    },
                  );
                }),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Otra enfermedad o condición de salud',
                  hint: 'Especifique cuál',
                  icon: Icons.health_and_safety,
                  controller: _otraEnfermedadCtrl,
                  onChanged: (val) => otraEnfermedad = val,
                ),
              ],
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        await _saveHistorial();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A99D),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'GUARDAR HISTORIAL CLÍNICO',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Widget helpers ──────────────────────────────────────────────────────────

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    String? subtitle,
    required List<Widget> children,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A99D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: const Color(0xFF00A99D), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00A99D),
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF00A99D)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF00A99D)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    final safeValue = (value != null && items.contains(value)) ? value : null;
    return DropdownButtonFormField<String>(
      value: safeValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.arrow_drop_down_circle, color: Color(0xFF00A99D)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: (val) {
        setState(() => onChanged(val));
        _saveDraft();
      },
    );
  }

  Widget _buildRadioGroup({
    required String label,
    required String? value,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: options.map((option) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: option,
                  groupValue: value,
                  onChanged: (String? val) {
                    setState(() => onChanged(val));
                    _saveDraft();
                  },
                  activeColor: const Color(0xFF00A99D),
                ),
                Text(option),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCheckboxGroup({
    required String label,
    required List<String> options,
    required List<String> selectedValues,
    required Function(String) onChangedMulti,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: options.map((option) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: selectedValues.contains(option),
                  onChanged: (val) {
                    setState(() => onChangedMulti(option));
                    _saveDraft();
                  },
                  activeColor: const Color(0xFF00A99D),
                ),
                Text(option),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF00A99D),
        ),
        Expanded(child: Text(label)),
      ],
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Color(0xFF00A99D), size: 60),
        content: const Text(
          'Historial clínico guardado exitosamente',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/');
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A99D)),
              child: const Text('Aceptar'),
            ),
          ),
        ],
      ),
    );
  }
}
