import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/contacto_service.dart';

class ContactoPublicoScreen extends StatefulWidget {
  const ContactoPublicoScreen({super.key});

  @override
  State<ContactoPublicoScreen> createState() => _ContactoPublicoScreenState();
}

class _ContactoPublicoScreenState extends State<ContactoPublicoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ContactoService();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _finalidadCtrl = TextEditingController();

  List<Map<String, dynamic>> _paises = [];
  String? _paisSeleccionado;
  bool _cargandoPaises = true;
  bool _enviando = false;
  bool _enviado = false;

  @override
  void initState() {
    super.initState();
    _cargarPaises();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _finalidadCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarPaises() async {
    final paises = await _service.obtenerPaises();
    if (mounted) {
      setState(() {
        _paises = paises;
        _cargandoPaises = false;
      });
    }
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_paisSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un país')),
      );
      return;
    }

    setState(() => _enviando = true);

    final result = await _service.enviarSolicitud(
      nombre: _nombreCtrl.text.trim(),
      correo: _correoCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      finalidad: _finalidadCtrl.text.trim(),
      paisId: _paisSeleccionado!,
    );

    if (mounted) {
      setState(() => _enviando = false);
      if (result['success'] == true) {
        setState(() => _enviado = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error al enviar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Contáctanos'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: _enviado ? _buildExito() : _buildFormulario(colorScheme),
    );
  }

  // ── Exit screen after send ─────────────────────────────────────────
  Widget _buildExito() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            const Text(
              '¡Mensaje enviado!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Hemos recibido tu solicitud. Uno de nuestros administradores se pondrá en contacto contigo pronto.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => setState(() {
                _enviado = false;
                _nombreCtrl.clear();
                _correoCtrl.clear();
                _telefonoCtrl.clear();
                _finalidadCtrl.clear();
                _paisSeleccionado = null;
              }),
              icon: const Icon(Icons.send_outlined),
              label: const Text('Enviar otra solicitud'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Contact formulary ────────────────────────────────────────────────
  Widget _buildFormulario(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
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
            child: Column(
              children: [
                Icon(Icons.public,
                    size: 40, color: colorScheme.onPrimaryContainer),
                const SizedBox(height: 8),
                Text(
                  'Latinoamérica Comparte',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completa el formulario y te contactamos',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Form
          Form(
            key: _formKey,
            child: Column(
              children: [
                _campo(_nombreCtrl, 'Nombre completo *',
                    required: true, icon: Icons.person_outline),
                _campo(_correoCtrl, 'Correo electrónico *',
                    required: true,
                    icon: Icons.email_outlined,
                    tipo: TextInputType.emailAddress, validador: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  if (!v.contains('@') || !v.contains('.')) {
                    return 'Correo no válido';
                  }
                  return null;
                }),
                _campo(_telefonoCtrl, 'Teléfono *',
                    required: true,
                    icon: Icons.phone_outlined,
                    tipo: TextInputType.phone),
                _campo(_finalidadCtrl, '¿En qué podemos ayudarte? *',
                    required: true, icon: Icons.help_outline, maxLines: 3),

                // Dropdown de país
                const SizedBox(height: 4),
                _cargandoPaises
                    ? const LinearProgressIndicator()
                    : DropdownButtonFormField<String>(
                        value: _paisSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'País *',
                          prefixIcon: const Icon(Icons.flag_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _paises.map((p) {
                          return DropdownMenuItem<String>(
                            value: p['_id'] as String,
                            child: Text(p['nombre'] as String),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _paisSeleccionado = val),
                      ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _enviando ? null : _enviar,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _enviando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Enviar solicitud',
                            style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _campo(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    IconData? icon,
    TextInputType tipo = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validador,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: tipo,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: validador ??
            (required
                ? (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null
                : null),
      ),
    );
  }
}
