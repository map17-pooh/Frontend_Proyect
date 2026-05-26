import 'package:flutter/material.dart';
import 'services/api_service.dart';

class RecuperarPassword extends StatefulWidget {
  const RecuperarPassword({super.key});

  @override
  State<RecuperarPassword> createState() => _RecuperarPasswordState();
}

class _RecuperarPasswordState extends State<RecuperarPassword> {
  final _emailFormKey = GlobalKey<FormState>();
  final _confirmFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _tokenSent = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _solicitarToken() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ApiService.solicitarResetPassword(_emailController.text.trim());
      setState(() => _tokenSent = true);
      _showInfo('Se ha enviado el código de recuperación a tu correo.');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Error de conexión. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmarReset() async {
    if (!_confirmFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ApiService.confirmarResetPassword(
        _tokenController.text.trim(),
        _newPasswordController.text,
      );
      if (mounted) {
        _showInfo('Contraseña actualizada exitosamente.');
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Error de conexión. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showInfo(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF00A99D)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF00A99D),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Icon(Icons.lock_reset, size: 80, color: Color(0xFF00A99D)),
            const SizedBox(height: 16),
            const Text(
              'Recupera tu contraseña',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A99D)),
            ),
            const SizedBox(height: 8),
            Text(
              _tokenSent
                  ? 'Ingresa el código recibido y tu nueva contraseña.'
                  : 'Ingresa tu correo para recibir el código de recuperación.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            if (!_tokenSent) ...[
              Form(
                key: _emailFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: const Icon(Icons.email, color: Color(0xFF00A99D)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Campo requerido';
                        if (!v.contains('@')) return 'Email inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF00A99D))
                        : ElevatedButton(
                            onPressed: _solicitarToken,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00A99D),
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text('ENVIAR CÓDIGO',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                  ],
                ),
              ),
            ] else ...[
              Form(
                key: _confirmFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _tokenController,
                      decoration: InputDecoration(
                        labelText: 'Código de recuperación',
                        prefixIcon: const Icon(Icons.key, color: Color(0xFF00A99D)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña',
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF00A99D)),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscureNew
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey),
                          onPressed: () =>
                              setState(() => _obscureNew = !_obscureNew),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Campo requerido';
                        if (v.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirmar nueva contraseña',
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00A99D)),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey),
                          onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo requerido';
                        if (v != _newPasswordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF00A99D))
                        : ElevatedButton(
                            onPressed: _confirmarReset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00A99D),
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text('CAMBIAR CONTRASEÑA',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => _tokenSent = false),
                      child: const Text('Reenviar código',
                          style: TextStyle(color: Color(0xFF00A99D))),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
