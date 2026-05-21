import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/usuarios_provider.dart';
import '../../../features/paises/providers/paises_provider.dart';

class FormularioUsuarioScreen extends StatefulWidget {
  const FormularioUsuarioScreen({super.key});

  @override
  State<FormularioUsuarioScreen> createState() =>
      _FormularioUsuarioScreenState();
}

class _FormularioUsuarioScreenState extends State<FormularioUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _rol = 'editor';
  String? _paisId;
  bool _guardando = false;
  bool _obscure = true;

  final _rolesConPais = ['admin_pais', 'editor', 'usuario_general'];

  @override
  void initState() {
    super.initState();
    // Load paises if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paises = context.read<PaisesProvider>();
      if (paises.paises.isEmpty) {
        paises.cargar();
      }
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final data = {
      'nombre': _nombreCtrl.text.trim(),
      'correo': _correoCtrl.text.trim(),
      'password': _passCtrl.text,
      'rol': _rol,
      'pais_asignado': _rolesConPais.contains(_rol) ? _paisId : null,
    };

    final ok = await context.read<UsuariosProvider>().crear(data);
    if (mounted) {
      setState(() => _guardando = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Usuario creado'), backgroundColor: Colors.green),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error al crear usuario'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paises = context.watch<PaisesProvider>().paises;
    final necesitaPais = _rolesConPais.contains(_rol);

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo usuario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _campo(_nombreCtrl, 'Nombre completo *', required: true),
              _campo(_correoCtrl, 'Correo electrónico *',
                  required: true, tipo: TextInputType.emailAddress),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Contraseña *',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo requerido';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
              ),
              DropdownButtonFormField<String>(
                value: _rol,
                decoration: const InputDecoration(labelText: 'Rol *'),
                items: const [
                  DropdownMenuItem(
                      value: 'superadmin', child: Text('Super Admin')),
                  DropdownMenuItem(
                      value: 'admin_pais', child: Text('Admin País')),
                  DropdownMenuItem(value: 'editor', child: Text('Editor')),
                  DropdownMenuItem(
                      value: 'usuario_general', child: Text('Usuario General')),
                ],
                onChanged: (val) => setState(() {
                  _rol = val!;
                  _paisId = null;
                }),
              ),
              if (necesitaPais) ...[
                const SizedBox(height: 16),
                Consumer<PaisesProvider>(
                  builder: (context, paisesProvider, _) {
                    if (paisesProvider.status == PaisesStatus.loading) {
                      return const LinearProgressIndicator();
                    }
                    return DropdownButtonFormField<String>(
                      value: _paisId,
                      decoration: const InputDecoration(labelText: 'País *'),
                      items: paisesProvider.paises
                          .map((p) => DropdownMenuItem(
                              value: p.id, child: Text(p.nombre)))
                          .toList(),
                      validator: (v) => v == null ? 'Selecciona un país' : null,
                      onChanged: (val) => setState(() => _paisId = val),
                    );
                  },
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _guardando ? null : _guardar,
                  child: _guardando
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text('Crear usuario'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(TextEditingController ctrl, String label,
      {bool required = false, TextInputType tipo = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: tipo,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null
            : null,
      ),
    );
  }
}
