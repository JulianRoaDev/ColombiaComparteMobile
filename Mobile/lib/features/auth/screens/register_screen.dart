import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../../solicitudes/services/contacto_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _authService     = AuthService();
  final _contactoService = ContactoService();

  final _nombreCtrl   = TextEditingController();
  final _correoCtrl   = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  String  _rolSeleccionado = 'usuario_general';
  String? _paisSeleccionado;
  List<Map<String, dynamic>> _paises = [];
  bool _cargandoPaises = true;
  bool _guardando      = false;
  bool _obscurePass    = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _cargarPaises();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarPaises() async {
    final paises = await _contactoService.obtenerPaises();
    if (mounted) setState(() { _paises = paises; _cargandoPaises = false; });
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _guardando = true);

    final result = await _authService.register(
      nombre:   _nombreCtrl.text.trim(),
      correo:   _correoCtrl.text.trim(),
      password: _passCtrl.text,
      rol:      _rolSeleccionado,
      paisId:   _paisSeleccionado,
    );

    if (mounted) {
      setState(() => _guardando = false);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cuenta creada! Inicia sesión'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(children: [
                  Icon(Icons.person_add_outlined,
                      size: 40, color: colorScheme.onPrimaryContainer),
                  const SizedBox(height: 8),
                  Text('Únete a Latinoamérica Comparte',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.onPrimaryContainer,
                      )),
                ]),
              ),
              const SizedBox(height: 28),

              // Campos
              _campo(_nombreCtrl,  'Nombre completo *',     required: true, icon: Icons.person_outline),
              _campo(_correoCtrl,  'Correo electrónico *',  required: true, icon: Icons.email_outlined,
                  tipo: TextInputType.emailAddress,
                  validador: (v) {
                    if (v == null || v.isEmpty) return 'Campo requerido';
                    if (!v.contains('@')) return 'Correo inválido';
                    return null;
                  }),
              _campoPwd(_passCtrl,    'Contraseña *',         _obscurePass,
                  () => setState(() => _obscurePass = !_obscurePass)),
              _campoPwd(_confirmCtrl, 'Confirmar contraseña *', _obscureConfirm,
                  () => setState(() => _obscureConfirm = !_obscureConfirm)),

              // Rol
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _rolSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Tipo de cuenta *',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                items: const [
                  DropdownMenuItem(value: 'usuario_general', child: Text('Usuario general')),
                  DropdownMenuItem(value: 'editor',          child: Text('Editor de contenido')),
                ],
                onChanged: (val) => setState(() => _rolSeleccionado = val!),
              ),
              const SizedBox(height: 16),

              // País
              _cargandoPaises
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _paisSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'País *',
                        prefixIcon: const Icon(Icons.flag_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      items: _paises.map((p) => DropdownMenuItem<String>(
                        value: p['_id'] as String,
                        child: Text(p['nombre'] as String),
                      )).toList(),
                      validator: (v) => v == null ? 'Selecciona un país' : null,
                      onChanged: (val) => setState(() => _paisSeleccionado = val),
                    ),
              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _guardando ? null : _registrar,
                  child: _guardando
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text('Crear cuenta', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(
    TextEditingController ctrl, String label, {
    bool required = false, IconData? icon,
    TextInputType tipo = TextInputType.text,
    String? Function(String?)? validador,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
        validator: validador ??
            (required ? (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null : null),
      ),
    );
  }

  Widget _campoPwd(TextEditingController ctrl, String label,
      bool obscure, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: onToggle,
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Campo requerido';
          if (v.length < 6) return 'Mínimo 6 caracteres';
          return null;
        },
      ),
    );
  }
}