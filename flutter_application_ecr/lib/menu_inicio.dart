import 'package:flutter/material.dart';
import 'login_interno_admin.dart';
import 'login_usuario_externo.dart';
import 'modulo_educativo.dart';

class MenuInicio extends StatefulWidget {
  const MenuInicio({super.key});

  @override
  State<MenuInicio> createState() => _MenuInicioState();
}

class _MenuInicioState extends State<MenuInicio> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> carouselItems = [
    {
      'image': 'https://images.unsplash.com/photo-1638202993928-7267aad84c31?w=600&auto=format&fit=crop&q=60',
      'title': 'Educación Inclusiva',
    },
    {
      'image': 'https://images.unsplash.com/photo-1575998064976-9df66085cc83?w=600&auto=format&fit=crop&q=60',
      'title': 'Comunidad Educativa',
    },
    {
      'image': 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=600&auto=format&fit=crop&q=60',
      'title': 'Innovación Tecnológica',
    },
    {
      'image': 'https://media.istockphoto.com/id/526040713/es/foto/ginec%C3%B3logo-explicar-girl-per%C3%ADodo-menstrual.jpg?s=2048x2048&w=is&k=20&c=_GOWDqQ-QFmfmuN_kY8Jr7ORHUHaoVDWuwCaLQzh_M4=',
      'title': 'Diversidad e Inclusión',
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), _autoPlayCarousel);
  }

  void _autoPlayCarousel() {
    if (_pageController.hasClients) {
      int nextPage = _currentPage + 1;
      if (nextPage >= carouselItems.length) nextPage = 0;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      Future.delayed(const Duration(seconds: 5), _autoPlayCarousel);
    }
  }

  void _navigateToLoginInterno() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginInternoAdmin()),
    );
  }

  void _navigateToLoginExterno() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginUsuarioExterno()),
    );
  }

  void _navigateToModuloEducativo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ModuloEducativo()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 52,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            const SizedBox(width: 10),
            const Text(
              'PlanificApp',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        toolbarHeight: 70,
        centerTitle: true,
        backgroundColor: const Color(0xFF00A99D),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          // Botón para acceso interno (Administrador/Interno)
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
              onPressed: _navigateToLoginInterno,
              tooltip: 'Acceso Interno (Admin/Interno)',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Botón Módulo Educativo
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00A99D).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _navigateToModuloEducativo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A99D),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'MÓDULO EDUCATIVO',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                'Accede a información sobre salud sexual y reproductiva',
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Botón Iniciar Sesión Usuario Externo
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00A99D).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _navigateToLoginExterno,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A99D),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.login, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'INICIAR SESIÓN',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                'Ingresa a tu perfil y accede a tus servicios',
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int page) => setState(() => _currentPage = page),
                    itemCount: carouselItems.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(carouselItems[index]['image']!),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                carouselItems[index]['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        carouselItems.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index ? const Color(0xFF00A99D) : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, const Color(0xFF00A99D).withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, size: 28, color: Color(0xFF00A99D)),
                      SizedBox(width: 12),
                      Text(
                        '¿Qué es PlanificApp?',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Es una plataforma de orientacion y asesoria en salud sexual con enfasis en anticoncepcion para adolescentes y jovenes',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Servicios que incluye:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint('✓ Módulo de educación'),
                  _buildBulletPoint('✓ Módulo de orientacion y/o asesoria'),
                  _buildBulletPoint('✓ Módulo de seguimiento'),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A99D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people, color: Color(0xFF00A99D), size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('¡Regístrate y empieza tu camino!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 4),
                              Text('Inicia sesión para acceder a todos los servicios', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF00A99D), size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}

