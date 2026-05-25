import 'package:audioguia_web/model/monumento_model.dart';
import 'package:audioguia_web/provider/monumentos_provider.dart';
import 'package:audioguia_web/provider/tema_provider.dart';
import 'package:audioguia_web/presentation/widgets/app_bar_principal.dart';
import 'package:audioguia_web/presentation/widgets/label_campo.dart';
import 'package:audioguia_web/presentation/widgets/menu_lateral.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EditaMonumentoScreen extends StatefulWidget {
  final String monumentoId;

  const EditaMonumentoScreen({super.key, required this.monumentoId});

  @override
  State<EditaMonumentoScreen> createState() => _EditaMonumentoScreenState();
}

class _EditaMonumentoScreenState extends State<EditaMonumentoScreen> {
  final _formKey = GlobalKey<FormState>();

  Monumento? _monumento;
  bool _isLoading = true;
  String _categoriaSeleccionada = 'Monumentos Históricos';
  String _estadoSeleccionado = 'Activo';
  String _sinopsisSeleccionada = 'No';
  String _descNombreSeleccionada = 'Texto Infantil';

  final _nombreController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _likesController = TextEditingController();
  final _descContenidoController = TextEditingController();

  final List<String> _opcionesDescNombre = [
    'Texto Infantil',
    'Sinopsis Esp',
    'English Audio Text',
    'Texto Audio',
    'English Sinopsis'
  ];

  final Map<String, String> _categoriasMap = {
    'Monumentos Históricos': '1',
    'Iglesias': '2',
    'Fuentes': '3',
    'Parques': '4',
  };

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _likesController.dispose();
    _descContenidoController.dispose(); 
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    try {
      final provider = context.read<GestionMonumentoProvider>();
      final data = await provider.cargarMonumento(widget.monumentoId);
      setState(() {
        _monumento = data;
        _nombreController.text = data.nombre;
        _latController.text = data.latitud.toString();
        _lonController.text = data.longitud.toString();
        _likesController.text = data.likes.toString();
        _descContenidoController.text = data.descripcionContenido;
        _sinopsisSeleccionada = data.sinopsis == true ? 'Sí' : 'No';

        if (_opcionesDescNombre.contains(data.descripcionNombre)) {
          _descNombreSeleccionada = data.descripcionNombre;
        } else {
          _descNombreSeleccionada = 'Texto Infantil';
        }

        _categoriaSeleccionada = _obtenerNombreCategoria(data.categoria);
        _estadoSeleccionado = data.activo ? 'Activo' : 'Desactivado';
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Error al cargar monumento: $e'),
            backgroundColor: Colors.red,
          ),
        );
        context.go('/rendimiento');
      }
    }
  }

  String _obtenerNombreCategoria(String id) {
    return _categoriasMap.entries
        .firstWhere(
          (element) => element.value == id,
          orElse: () => const MapEntry('Monumentos Históricos', '1'),
        )
        .key;
  }

  Future<void> _ejecutarActualizacion() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate() || _monumento == null) return;

    setState(() => _isLoading = true);

    final double lat = double.tryParse(_latController.text) ?? 37.7214;
    final double lon = double.tryParse(_lonController.text) ?? -4.0321;
    final int likes = int.tryParse(_likesController.text) ?? 0;
    final String tagId = _categoriasMap[_categoriaSeleccionada] ?? '1';

    final monumentoActualizado = Monumento(
      id: _monumento!.id,
      nombre: _nombreController.text,
      categoria: tagId,
      accesible: _monumento!.accesible,
      activo: _estadoSeleccionado == 'Activo',
      paraNinos: _monumento!.paraNinos,
      idioma: _monumento!.idioma,
      latitud: lat,
      longitud: lon,
      likes: likes,
      sinopsis: _sinopsisSeleccionada == 'Sí',
      descripcionContenido: _descContenidoController.text,
      descripcionNombre: _descNombreSeleccionada, 
      imagenUrl: _monumento!.imagenUrl,
      audioUrl: _monumento!.audioUrl,
      descripcionId: _monumento!.descripcionId,
    );

    try {
      final provider = context.read<GestionMonumentoProvider>();
      final exito = await provider.editarMonumento(monumentoActualizado);

      if (mounted) {
        if (exito) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Monumento actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/rendimiento');
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✗ Error al actualizar el monumento'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Error al actualizar en el servidor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _eliminar() async {
    if (_monumento == null) return;
    final provider = context.read<GestionMonumentoProvider>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: Text(
          "¿Estás seguro de que deseas eliminar permanentemente '${_monumento?.nombre}'? Esta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      setState(() => _isLoading = true);
      try {
        final exito = await provider.eliminarMonumento(widget.monumentoId);
        if (mounted) {
          if (exito) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Monumento eliminado con éxito'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/rendimiento');
          } else {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✗ Error al eliminar el monumento'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✗ Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<TemaProvider>().isDarkMode;
    final dividerColor = isDarkMode ? Colors.white12 : Colors.grey[200]!;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBarPrincipal(
        isDarkMode: isDarkMode,
        onToggleDarkMode: () => context.read<TemaProvider>().toggleDarkMode(),
        icono: Icons.account_balance_outlined,
        titulo: 'Editar Monumento',
      ),
      body: Row(
        children: [
          MenuLateral(rutaActual: '/monumentos/editar', isDarkMode: isDarkMode),
          VerticalDivider(width: 1, color: dividerColor),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF008F68)),
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: _FormularioMonumento(
                              isDarkMode: isDarkMode,
                              nombreController: _nombreController,
                              latController: _latController,
                              lonController: _lonController,
                              likesController: _likesController,
                              descContenidoController: _descContenidoController, 
                              categoria: _categoriaSeleccionada,
                              estado: _estadoSeleccionado,
                              sinopsis: _sinopsisSeleccionada, 
                              descNombre: _descNombreSeleccionada, 
                              opcionesDescNombre: _opcionesDescNombre, 
                              imagenesUrls: _monumento?.imagenUrl != null ? [_monumento!.imagenUrl!] : [],
                              onCategoriaChanged: (val) {
                                if (val != null) setState(() => _categoriaSeleccionada = val);
                              },
                              onEstadoChanged: (val) {
                                if (val != null) setState(() => _estadoSeleccionado = val);
                              },
                              onSinopsisChanged: (val) { 
                                if (val != null) setState(() => _sinopsisSeleccionada = val);
                              },
                              onDescNombreChanged: (val) { 
                                if (val != null) setState(() => _descNombreSeleccionada = val);
                              },
                            ),
                          ),
                        ),
                        _buildFooter(context, isDarkMode),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDarkMode) {
    final footerBg = isDarkMode ? const Color(0xFF1E2A3A) : Colors.white;
    final footerBorder = isDarkMode ? Colors.white12 : Colors.grey[200]!;
    final cancelTextColor = isDarkMode ? Colors.grey[300]! : const Color(0xFF495057);
    final cancelBorderColor = isDarkMode ? Colors.white24 : const Color(0xFFDEE2E6);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: footerBg,
        border: Border(top: BorderSide(color: footerBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                context.read<GestionMonumentoProvider>().limpiarArchivos();
                context.go('/rendimiento');
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: cancelBorderColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Cancelar', style: TextStyle(color: cancelTextColor)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: _eliminar,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Eliminar Monumento',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _ejecutarActualizacion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008F68),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text(
                'Guardar Cambios',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormularioMonumento extends StatelessWidget {
  final bool isDarkMode;
  final TextEditingController nombreController;
  final TextEditingController latController;
  final TextEditingController lonController;
  final TextEditingController likesController;
  final TextEditingController descContenidoController;

  final String categoria;
  final String estado;
  final String sinopsis; 
  final String descNombre; 
  final List<String> opcionesDescNombre; 

  final ValueChanged<String?> onCategoriaChanged;
  final ValueChanged<String?> onEstadoChanged;
  final ValueChanged<String?> onSinopsisChanged;
  final ValueChanged<String?> onDescNombreChanged; 

  const _FormularioMonumento({
    required this.isDarkMode,
    required this.nombreController,
    required this.latController,
    required this.lonController,
    required this.likesController,
    required this.descContenidoController,
    required this.categoria,
    required this.estado,
    required this.sinopsis,
    required this.descNombre,
    required this.opcionesDescNombre,
    this.imagenesUrls = const [],
    required this.onCategoriaChanged,
    required this.onEstadoChanged,
    required this.onSinopsisChanged,
    required this.onDescNombreChanged,
  });

  final List<String> imagenesUrls;

  Color get _fieldFill => isDarkMode ? const Color(0xFF1E2A3A) : const Color(0xFFF8F9FA);
  Color get _fieldBorder => isDarkMode ? Colors.white24 : const Color(0xFFDEE2E6);
  Color get _hintColor => isDarkMode ? Colors.grey[500]! : Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imagenesUrls.isNotEmpty) ...[
          const LabelCampo(label: 'Imágenes Actuales'),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imagenesUrls.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(imagenesUrls[index], fit: BoxFit.contain),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imagenesUrls[index],
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 120, width: 120, color: _fieldFill,
                          child: Center(
                            child: Icon(Icons.broken_image, size: 30, color: _hintColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
        const LabelCampo(label: 'Nombre del Monumento'),
        const SizedBox(height: 8),
        _buildTextField(textoGuia: 'Ej: Castillo de la Peña', controller: nombreController),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LabelCampo(label: 'Categoría'),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: categoria,
                    items: const ['Monumentos Históricos', 'Iglesias', 'Fuentes', 'Parques'],
                    onChanged: onCategoriaChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LabelCampo(label: 'Estado'),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: estado,
                    items: ['Activo', 'Desactivado'],
                    onChanged: onEstadoChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LabelCampo(label: 'Nombre de la Descripción'),
                  const SizedBox(height: 8),
                  // MODIFICADO: Cambiado el cuadro de texto libre por el DropdownButton estricto
                  _buildDropdown(
                    value: descNombre,
                    items: opcionesDescNombre,
                    onChanged: onDescNombreChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LabelCampo(label: '¿Es Sinopsis?'),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: sinopsis,
                    items: const ['No', 'Sí'],
                    onChanged: onSinopsisChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const LabelCampo(label: 'Contenido de la Descripción'),
        const SizedBox(height: 8),
        _buildTextField(
          textoGuia: 'Escribe aquí la sinopsis completa o la información detallada del monumento...',
          controller: descContenidoController,
          maxLines: 4, 
        ),
        const SizedBox(height: 20),
        const LabelCampo(label: 'Ubicación'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildTextField(textoGuia: '37.7214', prefix: 'Lat', controller: latController)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(textoGuia: '-4.0321', prefix: 'Lon', controller: lonController)),
          ],
        ),
        const SizedBox(height: 20),

        const LabelCampo(label: 'Número de Likes'),
        const SizedBox(height: 8),
        _buildTextField(
          textoGuia: 'Ej: 142',
          controller: likesController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTextField({
    required String textoGuia,
    required TextEditingController controller,
    String? prefix,
    int maxLines = 1, 
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Este campo es obligatorio';
        if (keyboardType == TextInputType.number && int.tryParse(value) == null) {
          return 'Introduce un número válido';
        }
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: prefix != null
            ? Padding(padding: const EdgeInsets.all(12), child: Text(prefix, style: TextStyle(color: _hintColor)))
            : null,
        hintText: textoGuia,
        hintStyle: TextStyle(color: _hintColor, fontSize: 14),
        filled: true,
        fillColor: _fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _fieldBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF008F68))),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: isDarkMode ? const Color(0xFF1E2A3A) : Colors.white,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: _fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _fieldBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF008F68))),
      ),
    );
  }
}