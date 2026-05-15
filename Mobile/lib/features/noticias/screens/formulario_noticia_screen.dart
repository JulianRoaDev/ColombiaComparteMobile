import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/noticia_model.dart';
import '../providers/noticias_provider.dart';
import '../services/noticias_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../core/networks/dio_client.dart';

class FormularioNoticiaScreen extends StatefulWidget {
  final String? noticiaId;
  final NoticiaModel? noticia;
  const FormularioNoticiaScreen({super.key, this.noticiaId, this.noticia});

  bool get esEdicion => noticiaId != null;

  @override
  State<FormularioNoticiaScreen> createState() => _FormularioNoticiaScreenState();
}

class _FormularioNoticiaScreenState extends State<FormularioNoticiaScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _tituloCtrl   = TextEditingController();
  final _resumenCtrl  = TextEditingController();
  final _contenCtrl   = TextEditingController();
  final _autorCtrl    = TextEditingController();
  final _imagenCtrl   = TextEditingController();

  String  _estado  = 'borrador';
  String? _paisId;
  List<PaisModel> _paises  = [];
  bool _loading  = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final user = context.read<AuthProvider>().user!;

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

    if (widget.esEdicion) {
      try {
        final response = await DioClient.instance.get('/noticias');
        final lista = response.data as List;
        final dato = lista.firstWhere(
          (e) => e['_id'] == widget.noticiaId,
          orElse: () => null,
        );
        if (dato != null) {
          _tituloCtrl.text  = dato['titulo']    ?? '';
          _resumenCtrl.text = dato['resumen']   ?? '';
          _contenCtrl.text  = dato['contenido'] ?? '';
          _autorCtrl.text   = dato['autor']     ?? '';
          _imagenCtrl.text  = dato['imagen_url'] ?? '';
          _estado           = dato['estado']    ?? 'borrador';
          _paisId           = dato['pais']['_id'];
        }
      } catch (_) {}
    }

    setState(() => _cargando = false);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final data = {
      'titulo':    _tituloCtrl.text.trim(),
      'resumen':   _resumenCtrl.text.trim(),
      'contenido': _contenCtrl.text.trim(),
      'autor':     _autorCtrl.text.trim(),
      'imagen_url': _imagenCtrl.text.trim().isEmpty ? null : _imagenCtrl.text.trim(),
      'pais':      _paisId,
      'estado':    _estado,
    };

    final service = NoticiasService();
    final result = widget.esEdicion
        ? await service.actualizar(widget.noticiaId!, data)
        : await service.crear(data);

    setState(() => _loading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      await context.read<NoticiasProvider>().cargar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.esEdicion ? 'Noticia actualizada' : 'Noticia creada')),
      );
      context.go('/noticias');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Error al guardar')),
      );
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose(); _resumenCtrl.dispose(); _contenCtrl.dispose();
    _autorCtrl.dispose(); _imagenCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.esEdicion ? 'Editar Noticia' : 'Nueva Noticia'),
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
                      controller: _tituloCtrl,
                      decoration: const InputDecoration(labelText: 'Título *', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _resumenCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Resumen *', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _contenCtrl,
                      maxLines: 6,
                      decoration: const InputDecoration(labelText: 'Contenido *', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _autorCtrl,
                      decoration: const InputDecoration(labelText: 'Autor *', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 14),

                    if (user.isSuperAdmin && _paises.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: _paisId,
                        decoration: const InputDecoration(labelText: 'País *', border: OutlineInputBorder()),
                        items: _paises.map((p) =>
                            DropdownMenuItem(value: p.id, child: Text(p.nombre))).toList(),
                        onChanged: (val) => setState(() => _paisId = val),
                      )
                    else
                      InputDecorator(
                        decoration: const InputDecoration(labelText: 'País', border: OutlineInputBorder()),
                        child: Text(user.paisAsignado?.nombre ?? ''),
                      ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _imagenCtrl,
                      decoration: const InputDecoration(labelText: 'URL imagen (opcional)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      value: _estado,
                      decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
                      items: ['borrador', 'publicado']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => _estado = val!),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: _loading ? null : _guardar,
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : Text(widget.esEdicion ? 'Guardar cambios' : 'Publicar noticia'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}