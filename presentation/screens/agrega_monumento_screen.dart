import 'package:audioguia_web/provider/monumentos_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../provider/tema_provider.dart';
import '../../model/monumento_model.dart';
import '../widgets/app_bar_principal.dart';
import '../widgets/menu_lateral.dart';
import '../widgets/label_campo.dart';

class AgregaMonumentoPage extends StatefulWidget {
  const AgregaMonumentoPage({super.key});

  @override
  State<AgregaMonumentoPage> createState() => _AgregaMonumentoPageState();
}

class _AgregaMonumentoPageState extends State<AgregaMonumentoPage> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _likesController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _descContenidoController = TextEditingController();

  String _categoriaSeleccionada = 'Monumentos Históricos';
  String _estadoSeleccionado = 'Activo';
  String _paraNinosSeleccionado = 'No';
  String _idiomaSeleccionado = 'Español';
  String _sinopsisSeleccionada = 'No'; 
  String _descNombreSeleccionada = 'Texto Infantil'; 

  final Map<String, String> _categoriasMap = {
    'Monumentos Históricos': '1',
    'Iglesias': '2',
    'Fuentes': '3',
    'Parques': '4',
  };

  @override
  void dispose() {
    _nombreController.dispose();
    _likesController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _descContenidoController.dispose(); 
    super.dispose();
  }

  Future<void> _ejecutarGuardado() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final double lat = double.tryParse(_latController.text) ?? 37.7214;
    final double lon = double.tryParse(_lonController.text) ?? -4.0321;
    final int likes = int.tryParse(_likesController.text) ?? 0;
    final String tagIdId = _categoriasMap[_categoriaSeleccionada] ?? '1';
    final String codigoIdioma = _idiomaSeleccionado == 'Español' ? 'es' : 'en';

    final nuevoMonumento = Monumento(
      nombre: _nombreController.text,
      categoria: tagIdId,
      accesible: false,
      activo: _estadoSeleccionado == 'Activo',
      paraNinos: _paraNinosSeleccionado == 'Sí',
      idioma: codigoIdioma,
      latitud: lat,
      longitud: lon,
      likes: likes,
      sinopsis: _sinopsisSeleccionada == 'Sí',
      descripcionContenido: _descContenidoController.text,
      descripcionNombre: _descNombreSeleccionada, 
    );

    final exito = await context
        .read<GestionMonumentoProvider>()
        .guardarMonumento(nuevoMonumento);

    if (mounted) {
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Monumento guardado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✗ Error al guardar el monumento en el servidor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<TemaProvider>().isDarkMode;
    final nuevoMonumentoProv = context.watch<GestionMonumentoProvider>();
    final dividerColor = isDarkMode ? Colors.white12 : Colors.grey[200]!;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBarPrincipal(
        isDarkMode: isDarkMode,
        onToggleDarkMode: () => context.read<TemaProvider>().toggleDarkMode(),
        icono: Icons.account_balance_outlined,
        titulo: 'Añadir Nuevo Monumento',
      ),
      body: Row(
        children: [
          MenuLateral(
            rutaActual: '/monumentos/agregar',
            isDarkMode: isDarkMode,
          ),
          VerticalDivider(width: 1, color: dividerColor),
          Expanded(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _FormularioMonumento(
                        isDarkMode: isDarkMode,
                        nombreController: _nombreController,
                        likesController: _likesController,
                        latController: _latController,
                        lonController: _lonController,
                        descContenidoController: _descContenidoController,
                        categoria: _categoriaSeleccionada,
                        estado: _estadoSeleccionado,
                        paraNinos: _paraNinosSeleccionado,
                        idioma: _idiomaSeleccionado,
                        sinopsis: _sinopsisSeleccionada, 
                        descNombre: _descNombreSeleccionada, 
                        onCategoriaChanged: (val) {
                          if (val != null) setState(() => _categoriaSeleccionada = val);
                        },
                        onEstadoChanged: (val) {
                          if (val != null) setState(() => _estadoSeleccionado = val);
                        },
                        onParaNinosChanged: (val) {
                          if (val != null) setState(() => _paraNinosSeleccionado = val);
                        },
                        onIdiomaChanged: (val) {
                          if (val != null) setState(() => _idiomaSeleccionado = val);
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
                  _buildFooter(context, isDarkMode, nuevoMonumentoProv.isSaving),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDarkMode, bool isSaving) {
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
              onPressed: isSaving
                  ? null
                  : () {
                      context.read<GestionMonumentoProvider>().limpiarArchivos();
                      context.go('/dashboard');
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
            child: ElevatedButton(
              onPressed: isSaving ? null : _ejecutarGuardado,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008F68),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Guardar Monumento', style: TextStyle(color: Colors.white)),
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
  final TextEditingController likesController;
  final TextEditingController latController;
  final TextEditingController lonController;
  final TextEditingController descContenidoController;
  
  final String categoria;
  final String estado;
  final String paraNinos;
  final String idioma;
  final String sinopsis; 
  final String descNombre; 

  final ValueChanged<String?> onCategoriaChanged;
  final ValueChanged<String?> onEstadoChanged;
  final ValueChanged<String?> onParaNinosChanged;
  final ValueChanged<String?> onIdiomaChanged;
  final ValueChanged<String?> onSinopsisChanged; 
  final ValueChanged<String?> onDescNombreChanged; 

  const _FormularioMonumento({
    required this.isDarkMode,
    required this.nombreController,
    required this.likesController,
    required this.latController,
    required this.lonController,
    required this.descContenidoController,
    required this.categoria,
    required this.estado,
    required this.paraNinos,
    required this.idioma,
    required this.sinopsis,
    required this.descNombre,
    required this.onCategoriaChanged,
    required this.onEstadoChanged,
    required this.onParaNinosChanged,
    required this.onIdiomaChanged,
    required this.onSinopsisChanged,
    required this.onDescNombreChanged,
  });

  Color get _fieldFill => isDarkMode ? const Color(0xFF1E2A3A) : const Color(0xFFF8F9FA);
  Color get _fieldBorder => isDarkMode ? Colors.white24 : const Color(0xFFDEE2E6);
  Color get _uploadBoxBg => isDarkMode ? const Color(0xFF1E2A3A) : Colors.white;
  Color get _hintColor => isDarkMode ? Colors.grey[500]! : Colors.grey;
  Color get _subtextColor => isDarkMode ? Colors.grey[500]! : Colors.grey;

  @override
  Widget build(BuildContext context) {
    final nuevoMonumentoProv = context.watch<GestionMonumentoProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LabelCampo(label: 'Imagen Principal'),
        const SizedBox(height: 8),
        _buildUploadBox(
          icon: Icons.image_outlined,
          label: nuevoMonumentoProv.imagenNombre ?? 'Subir un archivo o arrastrar y soltar',
          sublabel: 'PNG, JPG, GIF hasta 10MB',
          onTap: () => nuevoMonumentoProv.seleccionarImagen(),
          hasFile: nuevoMonumentoProv.imagenNombre != null,
        ),
        const SizedBox(height: 20),

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
                    items: ['Monumentos Históricos', 'Iglesias', 'Fuentes', 'Parques'],
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
        const LabelCampo(label: 'Número de Me Gustas'),
        const SizedBox(height: 8),
        _buildTextField(textoGuia: 'Ej: 145', controller: likesController, keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LabelCampo(label: '¿Para Niños?'),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: paraNinos,
                    items: ['No', 'Sí'],
                    onChanged: onParaNinosChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LabelCampo(label: 'Idioma'),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: idioma,
                    items: ['Español', 'Inglés'],
                    onChanged: onIdiomaChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LabelCampo(label: 'Nombre de la Descripción'),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: descNombre,
                    items: [
                      'Texto Infantil',
                      'Sinopsis Esp',
                      'English Audio Text',
                      'Texto Audio',
                      'English Sinopsis'
                    ],
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
                    items: ['No', 'Sí'],
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
        const SizedBox(height: 24),

        const LabelCampo(label: 'Archivos de Audio'),
        const SizedBox(height: 8),
        _buildUploadBox(
          icon: Icons.mic_none_outlined,
          label: nuevoMonumentoProv.audioNombre ?? 'Subir audios o notas de voz',
          sublabel: 'MP3, WAV hasta 20MB',
          onTap: () => nuevoMonumentoProv.seleccionarAudio(),
          hasFile: nuevoMonumentoProv.audioNombre != null,
        ),
        const SizedBox(height: 24),

        const LabelCampo(label: 'Ubicación'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                textoGuia: '37.7214',
                prefix: 'Lat',
                controller: latController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                textoGuia: '-4.0321',
                prefix: 'Lon',
                controller: lonController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTextField({
    required String textoGuia,
    required TextEditingController controller,
    int maxLines = 1,
    String? prefix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
      validator: (value) => value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
      decoration: InputDecoration(
        prefixIcon: prefix != null
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: Text(prefix, style: TextStyle(color: _hintColor)),
              )
            : null,
        hintText: textoGuia,
        hintStyle: TextStyle(color: _hintColor, fontSize: 14),
        filled: true,
        fillColor: _fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF008F68)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF008F68)),
        ),
      ),
    );
  }

  Widget _buildUploadBox({
    required IconData icon,
    required String label,
    required String sublabel,
    required VoidCallback onTap,
    required bool hasFile,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
        decoration: BoxDecoration(
          color: _uploadBoxBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile ? const Color(0xFF008F68) : _fieldBorder,
            width: hasFile ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: hasFile ? const Color(0xFF008F68) : _hintColor, size: 40),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: hasFile ? 'Archivo seleccionado: ' : 'Subir un archivo ',
                    style: const TextStyle(color: Color(0xFF008F68), fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: hasFile ? label : label.replaceFirst('Subir un archivo', ''),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      fontWeight: hasFile ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(sublabel, style: TextStyle(color: _subtextColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}