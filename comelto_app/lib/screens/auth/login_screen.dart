import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../auth/role_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  bool _obscure = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(
            parent: _animCtrl, curve: Curves.easeIn));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final ok = await ref.read(authProvider.notifier).login(
      _identifierCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );
    if (ok && mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RoleRouter()));
    }
  }

  void _showParentDialog() {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.family_restroom,
              color: Color(0xFF7B1FA2)),
          SizedBox(width: 8),
          Text('Acceso Padres'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ingresa el código de tu hijo/a.',
              style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            TextField(
              controller: codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Código del estudiante',
                hintText: 'Ej: EST-2026-001',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B1FA2),
                foregroundColor: Colors.white),
            onPressed: () async {
              if (codeCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final ok = await ref
                  .read(authProvider.notifier)
                  .parentLookup(codeCtrl.text.trim());
              if (ok && mounted) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const RoleRouter()));
              }
            },
            child: const Text('Acceder'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth    = ref.watch(authProvider);
    final loading = auth.isLoading;
    final error   = auth.error;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF1565C0),
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.school,
                            size: 52,
                            color: Color(0xFF1565C0)),
                      ),
                      const SizedBox(height: 20),
                      const Text('Comelto Bolivia',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1)),
                      const Text('Sistema Escolar',
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: 14)),
                      const SizedBox(height: 36),

                      // Card del formulario
                      Card(
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text('Iniciar sesión',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Ingresa tus credenciales',
                                style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 13)),
                              const SizedBox(height: 20),

                              if (error != null) ...[
                                Container(
                                  padding:
                                      const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.red
                                            .withOpacity(0.5))),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error,
                                          color: Colors.red,
                                          size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(error,
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Usuario
                              TextField(
                                controller: _identifierCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Usuario o Email',
                                  prefixIcon: const Icon(
                                      Icons.person_outline),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                              10)),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Contraseña
                              TextField(
                                controller: _passwordCtrl,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  prefixIcon: const Icon(
                                      Icons.lock_outline),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                              10)),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscure
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () => setState(
                                        () => _obscure =
                                            !_obscure),
                                  ),
                                ),
                                onSubmitted: (_) => _login(),
                              ),
                              const SizedBox(height: 20),

                              // Botón ingresar
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed:
                                      loading ? null : _login,
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF1565C0),
                                    foregroundColor:
                                        Colors.white,
                                    shape:
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        10)),
                                    elevation: 3,
                                  ),
                                  child: loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child:
                                              CircularProgressIndicator(
                                                  color: Colors
                                                      .white,
                                                  strokeWidth:
                                                      2))
                                      : const Text('Ingresar',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight
                                                      .bold)),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Botón padres
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton.icon(
                                  onPressed:
                                      _showParentDialog,
                                  icon: const Icon(
                                      Icons.family_restroom,
                                      color:
                                          Color(0xFF7B1FA2)),
                                  label: const Text(
                                    'Soy padre de familia',
                                    style: TextStyle(
                                        color:
                                            Color(0xFF7B1FA2)),
                                  ),
                                  style:
                                      OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color:
                                            Color(0xFF7B1FA2)),
                                    shape:
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        10)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '© ${DateTime.now().year} Comelto Bolivia',
                        style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}