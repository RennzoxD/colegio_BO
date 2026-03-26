import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../auth/role_router.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  final bool isForced; // true = primer login obligatorio
  const ChangePasswordScreen({super.key, this.isForced = false});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends ConsumerState<ChangePasswordScreen> {
  final _passCtrl = TextEditingController();
  final _confCtrl = TextEditingController();
  bool _obscure1  = true;
  bool _obscure2  = true;
  bool _loading   = false;
  String? _error;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _error = null; });

    if (_passCtrl.text.length < 8) {
      setState(() =>
          _error = 'La contraseña debe tener al menos 8 caracteres');
      return;
    }
    if (_passCtrl.text != _confCtrl.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }

    setState(() => _loading = true);
    
    // Usar el provider en lugar del service
    final ok = await ref
        .read(authProvider.notifier)
        .changePassword(_passCtrl.text);
    
    setState(() => _loading = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('✅ Contraseña actualizada'),
            backgroundColor: Colors.green));
      // Navegar al router que detectará el nuevo estado
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RoleRouter()),
        (_) => false,
      );
    } else if (mounted) {
      setState(() =>
          _error = ref.read(authProvider).error ??
              'Error al cambiar contraseña');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícono
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0)
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_reset,
                          size: 48,
                          color: Color(0xFF1565C0)),
                    ),
                    const SizedBox(height: 16),
                    const Text('Cambiar Contraseña',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // Mensaje si es forzado
                    if (widget.isForced)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius:
                              BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.orange)),
                        child: const Row(
                          children: [
                            Icon(Icons.warning,
                                color: Colors.orange,
                                size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Debes cambiar tu contraseña '
                                'antes de continuar.',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (user != null) ...[
                      const SizedBox(height: 12),
                      Text('Usuario: ${user.name}',
                        style: TextStyle(
                            color: Colors.grey[600])),
                    ],
                    const SizedBox(height: 24),

                    // Error
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius:
                              BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.red)),
                        child: Text(_error!,
                          style: const TextStyle(
                              color: Colors.red)),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Nueva contraseña
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscure1,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña',
                        prefixIcon:
                            const Icon(Icons.lock),
                        border:
                            const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure1
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => setState(
                              () => _obscure1 = !_obscure1),
                        ),
                        helperText:
                            'Mínimo 8 caracteres',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirmar
                    TextField(
                      controller: _confCtrl,
                      obscureText: _obscure2,
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
                        prefixIcon:
                            const Icon(Icons.lock_outline),
                        border:
                            const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure2
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => setState(
                              () => _obscure2 = !_obscure2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8)),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Actualizar contraseña',
                                style: TextStyle(
                                    fontSize: 16)),
                      ),
                    ),

                    // Omitir si no es forzado
                    if (!widget.isForced) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}