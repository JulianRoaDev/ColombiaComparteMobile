import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/paises_provider.dart';
import '../../../shared/widgets/app_drawer.dart';

class PaisesScreen extends StatefulWidget {
  const PaisesScreen({super.key});

  @override
  State<PaisesScreen> createState() => _PaisesScreenState();
}

class _PaisesScreenState extends State<PaisesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaisesProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Países / Portales')),
      drawer: const AppDrawer(),
      body: Consumer<PaisesProvider>(
        builder: (context, provider, _) {
          if (provider.status == PaisesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.status == PaisesStatus.error) {
            return Center(child: Text(provider.errorMessage ?? 'Error'));
          }
          return RefreshIndicator(
            onRefresh: provider.cargar,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.paises.length,
              itemBuilder: (context, index) {
                final pais = provider.paises[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(pais.codigo)),
                    title: Text(pais.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Código: ${pais.codigo}'),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}