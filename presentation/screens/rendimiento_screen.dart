import 'package:audioguia_web/model/stats_model.dart';
import 'package:audioguia_web/provider/rendimiento_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_bar_principal.dart';
import '../widgets/menu_lateral.dart';
import 'package:provider/provider.dart';
import '../../provider/tema_provider.dart';
import '../../provider/config_provider.dart';

class RendimientoPage extends StatefulWidget {
  const RendimientoPage({super.key});

  @override
  State<RendimientoPage> createState() => _RendimientoPageState();
}

class _RendimientoPageState extends State<RendimientoPage> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<RendimientoProvider>();
    final configProv = context.read<ConfiguracionProvider>();
    Future.microtask(() {
      provider.fetchRendimiento();
      if (configProv.monumentos.isEmpty) {
        configProv.cargarConfiguracion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<TemaProvider>().isDarkMode;
    final rendimientoProv = context.watch<RendimientoProvider>();
    final dividerColor = isDarkMode ? Colors.white12 : Colors.grey[200]!;
    final bgColor = isDarkMode
        ? const Color(0xFF121212)
        : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBarPrincipal(
        isDarkMode: isDarkMode,
        onToggleDarkMode: () => context.read<TemaProvider>().toggleDarkMode(),
        icono: Icons.analytics_outlined,
        titulo: 'Rendimiento',
      ),
      body: Row(
        children: [
          MenuLateral(rutaActual: '/rendimiento', isDarkMode: isDarkMode),
          VerticalDivider(width: 1, color: dividerColor),
          Expanded(
            child: rendimientoProv.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF008F68)),
                  )
                : rendimientoProv.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          rendimientoProv.error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context
                              .read<RendimientoProvider>()
                              .fetchRendimiento(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF008F68),
                          ),
                          child: const Text(
                            'Reintentar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : rendimientoProv.data == null
                ? const Center(child: Text('No hay datos disponibles.'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _RendimientoContenido(
                      isDarkMode: isDarkMode,
                      data: rendimientoProv.data!,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RendimientoContenido extends StatelessWidget {
  final bool isDarkMode;
  final StatsModel data;

  const _RendimientoContenido({required this.isDarkMode, required this.data});

  Color get _cardBg => isDarkMode ? const Color(0xFF1E2A3A) : Colors.white;
  Color get _cardBorder =>
      isDarkMode ? Colors.white12 : const Color(0xFFF1F3F5);
  Color get _textPrimary => isDarkMode ? Colors.white : Colors.black87;
  Color get _textSecondary =>
      isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
  Color get _textMuted => isDarkMode ? Colors.grey[600]! : Colors.grey[400]!;
  Color get _thumbnailBg =>
      isDarkMode ? const Color(0xFF263040) : Colors.grey[200]!;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCabecera(),
        const SizedBox(height: 24),
        _buildEstadisticas(),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(flex: 3, child: _buildPopularMonuments(context))],
        ),
      ],
    );
  }

  Widget _buildCabecera() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rendimiento',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEstadisticas() {
    return Row(
      children: [
        _cardEstadistica(
          'Total Usuarios',
          data.totalUsuarios.toString(),
          Icons.people_outline,
          Colors.blue,
        ),
        const SizedBox(width: 16),
        _cardEstadistica(
          'Rutas Activas',
          data.rutasActivas.toString(),
          Icons.directions_walk,
          Colors.green,
        ),
        const SizedBox(width: 16),
        _cardEstadistica(
          'Consultas a la IA',
          data.peticionesIA.toString(),
          Icons.smart_toy_outlined,
          Colors.red,
        ),
      ],
    );
  }

  Widget _cardEstadistica(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(color: _textSecondary, fontSize: 13),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularMonuments(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Monumentos más Populares',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...data.monumentosPopulares.asMap().entries.map((entry) {
            int index = entry.key + 1;
            var monumento = entry.value;
            String? imagenUrl;
            try {
              final configProvider = context.watch<ConfiguracionProvider>();
              final mon = configProvider.monumentos.firstWhere(
                (m) => m.id == monumento.id,
              );
              imagenUrl = mon.imagenUrl;
            } catch (_) {}

            return _monumentRow(
              context,
              index.toString(),
              monumento.nombre,
              monumento.visitas,
              monumento.porcentaje,
              monumento.id,
              imagenUrl,
            );
          }),
        ],
      ),
    );
  }

  Widget _monumentRow(
    BuildContext context,
    String rank,
    String name,
    String stats,
    String percent,
    String? monumentoId,
    String? imagenUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Text(
            rank,
            style: TextStyle(color: _textMuted, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _thumbnailBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: imagenUrl != null && imagenUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imagenUrl,
                      fit: BoxFit.cover,
                      cacheWidth: 120,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_not_supported,
                        color: _textSecondary,
                        size: 20,
                      ),
                    ),
                  )
                : Icon(Icons.location_on, color: _textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                Text(
                  stats,
                  style: TextStyle(color: _textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            percent,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: _textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          if (monumentoId != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: _textSecondary,
              onPressed: () async {
                context.pushNamed(
                  'editar_monumento',
                  pathParameters: {'id': monumentoId},
                );
              },
            ),
        ],
      ),
    );
  }
}
