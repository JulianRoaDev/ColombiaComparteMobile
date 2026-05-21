import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/testimonio_model.dart';
import '../providers/testimonios_provider.dart';
import '../services/testimonios_services.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../core/networks/dio_client.dart';

class FormularioTestimonioScreen extends StatefulWidget {
  final TestimonioModel? testimonio;
  const FormularioTestimonioScreen({super.key, this.testimonio});

  bool get esEdicion => testimonio != null;

  @override
  State<FormularioTestimonioScreen> createState() =>
      _FormularioTestimonioScreenState();
}

class _FormularioTestimonioScreenState
    extends State<FormularioTestimonioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _fotoCtrl = TextEditingController();
  final _textoCtrl = TextEditingController();
  final _igCtrl = TextEditingController();
  final _fbCtrl = TextEditingController();

  String _estado = 'borrador';
  String? _paisId;
  List<PaisModel> _paises = [];
  bool _loading = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    if (widget.esEdicion) {
      // ← widget.esEdicion
      final t = widget.testimonio!;
      _nombreCtrl.text = t.nombre;
      _fotoCtrl.text = t.fotoUrl;
      _textoCtrl.text = t.testimonio;
      _igCtrl.text = t.instagramUrl ?? '';
      _fbCtrl.text = t.facebookUrl ?? '';
      _estado = t.estado;
    }
    _init();
  }

  Future<void> _init() async {
    final user = context.read<AuthProvider>().user!;

    // Cargar lista de países (solo superadmin elige; los demás tienen fijo su país)
    if (user.isSuperAdmin) {
      try {
        final response = await DioClient.instance.get('/paises');
        _paises = (response.data as List)
            .map((e) => PaisModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (_paises.isNotEmpty) _paisId = _paises.first.id;
      } catch (_) {}
    } else {
      _paisId = user.paisAsignado!.id;
    }

    // Si es edición, precargar los datos del testimonio
    if (widget.esEdicion) {
      try {
        final response = await DioClient.instance.get('/testimonios');
        final lista = response.data as List;
        final dato = lista.firstWhere(
          (e) => e['_id'] == widget.testimonio,
          orElse: () => null,
        );
        if (dato != null) {
          _nombreCtrl.text = dato['nombre'] ?? '';
          _fotoCtrl.text = dato['foto_url'] ?? '';
          _textoCtrl.text = dato['testimonio'] ?? '';
          _igCtrl.text = dato['instagram_url'] ?? '';
          _fbCtrl.text = dato['facebook_url'] ?? '';
          _estado = dato['estado'] ?? 'borrador';
          _paisId = dato['pais']['_id'];
        }
      } catch (_) {}
    }

    setState(() => _cargando = false);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final user = context.read<AuthProvider>().user!;
    final paisId = user.paisAsignado?.id ?? '';

    final data = {
      'nombre': _nombreCtrl.text.trim(),
      'foto_url': _fotoCtrl.text.trim(),
      'testimonio': _textoCtrl.text.trim(),
      'pais': widget.esEdicion
          ? widget.testimonio!.pais.id // en edición, mantener el país original
          : paisId,
      'instagram_url': _igCtrl.text.trim().isEmpty ? null : _igCtrl.text.trim(),
      'facebook_url': _fbCtrl.text.trim().isEmpty ? null : _fbCtrl.text.trim(),
      'estado': _estado,
    };

    final provider = context.read<TestimoniosProvider>();
    bool ok;
    if (widget.esEdicion) {
      // ← widget.isEditing
      ok = await provider.editar(widget.testimonio!.id, data);
    } else {
      ok = await provider.crear(data);
    }

    if (mounted) {
      setState(() => _loading = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.esEdicion
                ? 'Testimonio actualizado'
                : 'Testimonio creado'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // ← pop en lugar de go para volver al listado
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error al guardar'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _fotoCtrl.dispose();
    _textoCtrl.dispose();
    _igCtrl.dispose();
    _fbCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user!;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.esEdicion ? 'Editar Testimonio' : 'Nuevo Testimonio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              // Fallback si no hay stack
              context.go(widget.esEdicion ? '/testimonios' : '/testimonios');
            }
          },
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nombre *', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _fotoCtrl,
                      decoration: const InputDecoration(
                          labelText: 'URL de foto *',
                          border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _textoCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                          labelText: 'Testimonio *',
                          border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 14),

                    // País: dropdown para superadmin, texto fijo para los demás
                    if (user.isSuperAdmin && _paises.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: _paisId,
                        decoration: const InputDecoration(
                            labelText: 'País *', border: OutlineInputBorder()),
                        items: _paises
                            .map((p) => DropdownMenuItem(
                                value: p.id, child: Text(p.nombre)))
                            .toList(),
                        onChanged: (val) => setState(() => _paisId = val),
                      )
                    else
                      InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'País', border: OutlineInputBorder()),
                        child: Text(user.paisAsignado?.nombre ?? ''),
                      ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _igCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Instagram (opcional)',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _fbCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Facebook (opcional)',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      value: _estado,
                      decoration: const InputDecoration(
                          labelText: 'Estado', border: OutlineInputBorder()),
                      items: ['borrador', 'publicado', 'despublicado']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => _estado = val!),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: _loading ? null : _guardar,
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2)
                            : Text(widget.esEdicion
                                ? 'Guardar cambios'
                                : 'Crear testimonio'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
