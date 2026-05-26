import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class ModuloEducativo extends StatefulWidget {
  const ModuloEducativo({super.key});

  @override
  State<ModuloEducativo> createState() => _ModuloEducativoState();
}

class _ModuloEducativoState extends State<ModuloEducativo> {
  String _searchQuery = '';

  List<TemaEducativo> get _temasFiltrados {
    if (_searchQuery.isEmpty) return temas;
    final q = _searchQuery.toLowerCase();
    return temas
        .where((t) =>
            t.titulo.toLowerCase().contains(q) ||
            t.descripcion.toLowerCase().contains(q))
        .toList();
  }

  final List<TemaEducativo> temas = [
    TemaEducativo(
      titulo: 'Higiene Íntima',
      icon: Icons.cleaning_services,
      color: Colors.blue,
      descripcion: 'Aprende sobre el cuidado e higiene personal',
      contenido: 'Contenido próximamente...',
    ),
    TemaEducativo(
      titulo: 'Derechos Sexuales y Reproductivos',
      icon: Icons.gavel,
      color: const Color(0xFF00A99D),
      descripcion: 'Conoce tus derechos y cómo ejercerlos',
      contenido: _derechosSexualesYReproductivos,
      subtemas: _subtemasDerechos,
    ),
    TemaEducativo(
      titulo: 'Métodos Anticonceptivos',
      icon: Icons.medical_services,
      color: Colors.purple,
      descripcion: 'Información sobre métodos para planificar',
      contenido: 'Contenido próximamente...',
    ),
    TemaEducativo(
      titulo: 'IVE (Interrupción Voluntaria del Embarazo)',
      icon: Icons.health_and_safety,
      color: Colors.orange,
      descripcion: 'Conoce tus derechos en salud sexual',
      contenido: 'Contenido próximamente...',
    ),
    TemaEducativo(
      titulo: 'Prevención de ITS',
      icon: Icons.shield,
      color: Colors.red,
      descripcion: 'Aprende a prevenir infecciones',
      contenido: 'Contenido próximamente...',
    ),
    TemaEducativo(
      titulo: 'Violencia de Género',
      icon: Icons.warning,
      color: Colors.deepPurple,
      descripcion: 'Identifica y previene la violencia',
      contenido: 'Contenido próximamente...',
    ),
    TemaEducativo(
      titulo: 'Anticoncepción post-aborto',
      icon: Icons.family_restroom,
      color: Colors.teal,
      descripcion: 'Información sobre cuidado post-procedimiento',
      contenido: 'Contenido próximamente...',
    ),
    TemaEducativo(
      titulo: 'Doble Protección',
      icon: Icons.security,
      color: Colors.indigo,
      descripcion: 'Usa dos métodos a la vez: protégete del embarazo y las ITS',
      contenido: 'Contenido próximamente...',
    ),
  ];

  static const Map<String, String> _subtemasDerechos = {
    '¿Qué son los Derechos Sexuales y Reproductivos?': '''
Los derechos sexuales y reproductivos, promovidos por la Organización Mundial de la Salud, son parte de tus derechos humanos. Esto significa que nadie puede quitártelos y que te ayudan a vivir tu sexualidad de forma libre, segura y responsable.
''',
    'Derechos Sexuales': '''
🔹 Derecho a vivir tu sexualidad libremente
Puedes vivir tu sexualidad de la manera que elijas, siempre que haya respeto, responsabilidad y consentimiento.

🔹 Derecho a decidir si tener o no relaciones sexuales
Nadie puede obligarte. Tú decides cuándo, cómo y con quién, o si no quieres hacerlo.

🔹 Derecho al respeto de tu cuerpo
Tu cuerpo es tuyo. Nadie debe tocarte, presionarte o hacerte sentir incómodo/a sin tu consentimiento.

🔹 Derecho a la privacidad y confidencialidad
Tu información personal y de salud debe ser protegida. Puedes hablar con profesionales de salud con confianza.

🔹 Derecho a recibir información y educación sexual
Tienes derecho a aprender sobre tu cuerpo, relaciones, prevención y cuidado para tomar decisiones informadas.

🔹 Derecho a ser tratado/a con respeto
Debes ser tratado/a con respeto, sin importar tu género, orientación sexual o forma de pensar.

🔹 Derecho a una vida libre de violencia sexual
Nadie puede obligarte a realizar actos sexuales. Si ocurre, tienes derecho a recibir ayuda y protección.

🔹 Derecho a expresar tu orientación e identidad
Puedes ser quien eres, expresar tus sentimientos y construir tu identidad sin miedo.
''',
    'Derechos Reproductivos': '''
🔹 Derecho a decidir si quieres tener hijos
Puedes decidir si quieres ser padre o madre, cuántos hijos tener y en qué momento de tu vida.

🔹 Derecho a usar métodos anticonceptivos
Puedes acceder a métodos seguros para prevenir embarazos y elegir el que mejor se adapte a ti.

🔹 Derecho a servicios de salud de calidad
Tienes derecho a recibir atención en salud con respeto, información clara y sin discriminación.

🔹 Derecho a la atención en embarazo, parto y posparto
Si decides tener un hijo, tienes derecho a atención segura y acompañamiento en todo el proceso.

🔹 Derecho a no ser obligado/a
Nadie puede obligarte a tener hijos, a no tenerlos o a someterte a procedimientos sin tu consentimiento.

🔹 Derecho a decidir con información
Todas tus decisiones deben basarse en información clara, veraz y suficiente.

🔹 Derecho a la planificación familiar
Puedes organizar tu vida reproductiva de acuerdo con tu proyecto de vida y bienestar.
''',
    '¿Cómo hacer cumplir tus derechos?': '''
1️⃣ INFÓRMATE
Conocer tus derechos es el primer paso. Tienes derecho a:
• Información clara y veraz
• Servicios de salud sexual y reproductiva
• Decidir sobre tu cuerpo
👉 Pregunta en tu institución educativa o centro de salud.

2️⃣ ACUDE A LOS SERVICIOS DE SALUD
Puedes ir a:
• Hospitales o centros de salud
• Servicios amigables para adolescentes y jóvenes

Tienes derecho a:
✔ Atención confidencial
✔ Trato digno
✔ Información clara

3️⃣ EXPRÉSATE Y EXIGE RESPETO
• Pregunta, opina y toma decisiones informadas
• Puedes decir "no" a procedimientos o situaciones que no deseas
• Nadie puede obligarte ni discriminarte

4️⃣ USA MECANISMOS DE PROTECCIÓN
Si vulneran tus derechos, puedes:
• Presentar una petición o queja (PQRS) en la institución de salud
• Solicitar apoyo a la Defensoría del Pueblo
• Acudir a la Personería Municipal
• Interponer una acción de tutela (cuando un derecho fundamental es vulnerado)

5️⃣ EN CASOS DE VIOLENCIA SEXUAL
• Acude de inmediato a un centro de salud
• Puedes denunciar en la Fiscalía General de la Nación
• También puedes recibir apoyo en comisarías de familia
👉 Tienes derecho a atención urgente, gratuita y sin barreras.

6️⃣ BUSCA APOYO
• Familia, docentes, orientadores
• Profesionales de salud
• Líneas de atención y apoyo psicológico
''',
    'Mensaje Clave': '''
👉 TUS DERECHOS NO SON UN FAVOR, SON UNA OBLIGACIÓN DEL ESTADO
👉 Puedes exigirlos con respeto, pero con firmeza
👉 NO ESTÁS SOLO/A: hay instituciones que deben protegerte
''',
    '📊 Infografía - Derechos Sexuales y Reproductivos': '''
[INFOGRAFÍA DISPONIBLE]
En esta sección encontrarás una representación visual de los derechos sexuales y reproductivos.
''',
  };

  static const String _derechosSexualesYReproductivos = '''
Los derechos sexuales y reproductivos, promovidos por la Organización Mundial de la Salud, son parte de tus derechos humanos. Esto significa que nadie puede quitártelos y que te ayudan a vivir tu sexualidad de forma libre, segura y responsable.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo Educativo', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF00A99D),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Buscar tema...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00A99D)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xFF00A99D))),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _temasFiltrados.length,
        itemBuilder: (context, index) {
          final tema = _temasFiltrados[index];
          return _buildTarjetaTema(context, tema);
        },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaTema(BuildContext context, TemaEducativo tema) {
    return GestureDetector(
      onTap: () {
        if (tema.subtemas != null && tema.subtemas!.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TemaDetalleDosPaneles(
                tema: tema,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TemaDetalleScreen(tema: tema),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tema.color,
              tema.color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: tema.color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                tema.icon,
                size: 45,
                color: tema.color,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                tema.titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                tema.descripcion,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ver más',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00A99D),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 12,
                    color: Color(0xFF00A99D),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla de detalle con dos paneles (para Derechos Sexuales y Reproductivos)
class TemaDetalleDosPaneles extends StatefulWidget {
  final TemaEducativo tema;

  const TemaDetalleDosPaneles({
    super.key,
    required this.tema,
  });

  @override
  State<TemaDetalleDosPaneles> createState() => _TemaDetalleDosPanelesState();
}

class _TemaDetalleDosPanelesState extends State<TemaDetalleDosPaneles> {
  String _subtemaSeleccionado = '';
  String _contenidoActual = '';
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  String get _progressKey => 'video_progress_${widget.tema.titulo}';

  @override
  void initState() {
    super.initState();
    if (widget.tema.subtemas != null && widget.tema.subtemas!.isNotEmpty) {
      _subtemaSeleccionado = widget.tema.subtemas!.keys.first;
      _contenidoActual = widget.tema.subtemas![_subtemaSeleccionado]!;
    }
    _initVideoPlayer();
  }

  Future<void> _saveVideoProgress() async {
    if (_videoController == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        _progressKey, _videoController!.value.position.inSeconds);
  }

  Future<void> _restoreVideoProgress() async {
    if (_videoController == null) return;
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt(_progressKey) ?? 0;
    if (seconds > 0) {
      await _videoController!.seekTo(Duration(seconds: seconds));
    }
  }

  void _initVideoPlayer() {
    _videoController = VideoPlayerController.asset('assets/videos/video_pre_derecho.mp4')
      ..initialize().then((_) async {
        await _restoreVideoProgress();
        if (mounted) setState(() => _isVideoInitialized = true);
      }).catchError((_) {
        _videoController = VideoPlayerController.network(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        )..initialize().then((_) async {
          await _restoreVideoProgress();
          if (mounted) setState(() => _isVideoInitialized = true);
        });
      });
  }

  void _cambiarSubtema(String subtema, String contenido) {
    setState(() {
      _subtemaSeleccionado = subtema;
      _contenidoActual = contenido;
    });
  }

  @override
  void dispose() {
    _saveVideoProgress();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tema.titulo, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: widget.tema.color,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Row(
        children: [
          // Panel izquierdo - Lista de subtemas (30% del ancho)
          Container(
            width: MediaQuery.of(context).size.width * 0.30,
            decoration: BoxDecoration(
              color: widget.tema.color.withOpacity(0.1),
              border: Border(
                right: BorderSide(
                  color: widget.tema.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.tema.subtemas?.length ?? 0,
              itemBuilder: (context, index) {
                String subtema = widget.tema.subtemas!.keys.elementAt(index);
                bool isSelected = _subtemaSeleccionado == subtema;
                return GestureDetector(
                  onTap: () => _cambiarSubtema(subtema, widget.tema.subtemas![subtema]!),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                widget.tema.color,
                                widget.tema.color.withOpacity(0.8),
                              ],
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? widget.tema.color : widget.tema.color.withOpacity(0.3),
                        width: isSelected ? 0 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: widget.tema.color.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      subtema,
                      style: TextStyle(
                        color: isSelected ? Colors.white : widget.tema.color,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Panel derecho - Contenido (70% del ancho)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contenido del subtema seleccionado
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(widget.tema.icon, size: 24, color: widget.tema.color),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _subtemaSeleccionado,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: widget.tema.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: Color(0xFF00A99D)),
                        SelectableText(
                          _contenidoActual,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Video - Se muestra DESPUÉS del texto
                  if (_subtemaSeleccionado == '¿Qué son los Derechos Sexuales y Reproductivos?' && _isVideoInitialized)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text(
                                    '📹 Video Educativo',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00A99D),
                                    ),
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: _videoController!.value.aspectRatio,
                                  child: VideoPlayer(_videoController!),
                                ),
                                VideoProgressIndicator(
                                  _videoController!,
                                  allowScrubbing: true,
                                  colors: const VideoProgressColors(
                                    playedColor: Color(0xFF00A99D),
                                    bufferedColor: Colors.grey,
                                    backgroundColor: Colors.black26,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  color: Colors.black87,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          _videoController!.value.isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (_videoController!.value.isPlaying) {
                                              _videoController!.pause();
                                              _saveVideoProgress();
                                            } else {
                                              _videoController!.play();
                                            }
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.replay, color: Colors.white),
                                        onPressed: () {
                                          _videoController!.seekTo(Duration.zero);
                                          _videoController!.play();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Infografía - Se muestra en el subtema de Infografía
                  if (_subtemaSeleccionado == '📊 Infografía - Derechos Sexuales y Reproductivos')
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                '📊 Infografía - Derechos Sexuales y Reproductivos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00A99D),
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/images/info_pre_derecho.jpg',
                              fit: BoxFit.contain,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  padding: const EdgeInsets.all(40),
                                  color: Colors.grey.shade200,
                                  child: Column(
                                    children: [
                                      const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                      const SizedBox(height: 8),
                                      const Text('Infografía no disponible', style: TextStyle(color: Colors.grey)),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Error: $error',
                                        style: const TextStyle(fontSize: 12, color: Colors.red),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pantalla de detalle normal (para otros temas)
class TemaDetalleScreen extends StatelessWidget {
  final TemaEducativo tema;

  const TemaDetalleScreen({
    super.key,
    required this.tema,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tema.titulo, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: tema.color,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              tema.color.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                      color: tema.color.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  tema.icon,
                  size: 50,
                  color: tema.color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tema.titulo,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: tema.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                width: 50,
                height: 3,
                decoration: BoxDecoration(
                  color: tema.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tema.descripcion,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SelectableText(
                  tema.contenido,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TemaEducativo {
  final String titulo;
  final IconData icon;
  final Color color;
  final String descripcion;
  final String contenido;
  final Map<String, String>? subtemas;

  TemaEducativo({
    required this.titulo,
    required this.icon,
    required this.color,
    required this.descripcion,
    required this.contenido,
    this.subtemas,
  });
}