class Monumento {
  final String? id;
  final String nombre;
  final String categoria;
  final bool accesible;
  final bool activo;
  final double latitud;
  final double longitud;
  final String? imagenUrl;
  final List<String> imagenesUrls;
  final String? audioUrl;
  final int likes;
  final bool paraNinos;
  final String idioma;
  final bool sinopsis;
  final String descripcionContenido;
  final String descripcionNombre;
  final int? descripcionId;
  final int? pictureId;
  final int? audioId;
  

  Monumento({
    this.id,
    required this.nombre,
    required this.categoria,
    required this.accesible,
    required this.activo,
    required this.latitud,
    required this.longitud,
    required this.paraNinos,
    required this.idioma,
    this.sinopsis = false,
    this.descripcionContenido = '',
    this.descripcionNombre = '',
    this.imagenUrl,
    this.imagenesUrls = const [],
    this.audioUrl,
    this.likes = 0,
    this.descripcionId,
    this.pictureId,
    this.audioId,
  });

  Monumento copyWith({
    String? id,
    String? nombre,
    String? categoria,
    bool? accesible,
    bool? activo,
    double? latitud,
    double? longitud,
    String? imagenUrl,
    List<String>? imagenesUrls,
    String? audioUrl,
    int? likes,
    bool? paraNinos,
    String? idioma,
    bool? sinopsis,
    String? descripcionContenido,
    String? descripcionNombre,
    int? descripcionId,
    int? pictureId,
    int? audioId,
  }) {
    return Monumento(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      accesible: accesible ?? this.accesible,
      activo: activo ?? this.activo,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      imagenesUrls: imagenesUrls ?? this.imagenesUrls,
      audioUrl: audioUrl ?? this.audioUrl,
      likes: likes ?? this.likes,
      paraNinos: paraNinos ?? this.paraNinos,
      idioma: idioma ?? this.idioma,
      sinopsis: sinopsis ?? this.sinopsis,
      descripcionContenido: descripcionContenido ?? this.descripcionContenido,
      descripcionNombre: descripcionNombre ?? this.descripcionNombre,
      descripcionId: descripcionId ?? this.descripcionId,
      pictureId: pictureId ?? this.pictureId,
      audioId: audioId ?? this.audioId,
    );
  }

  factory Monumento.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? coords = json['coordenates'];
    final double lat = coords != null ? (coords['lat'] ?? 0.0).toDouble() : 0.0;
    final double lon = coords != null ? (coords['lon'] ?? 0.0).toDouble() : 0.0;

    final List<dynamic>? listaAudios = json['audio'];
    final Map<String, dynamic>? primerAudio =
        (listaAudios != null && listaAudios.isNotEmpty)
        ? listaAudios[0] as Map<String, dynamic>
        : null;
    final int? audId = primerAudio != null ? primerAudio['id'] as int? : null;
    final pictureList = json['picture'] as List?;
    final List<String> allImages = [];
    String? firstImage;
    int? picId;

    if (pictureList != null && pictureList.isNotEmpty) {
      firstImage = pictureList[0]['url'];
      picId = pictureList[0]['id'] as int?;
      for (var pic in pictureList) {
        if (pic['url'] != null) {
          allImages.add(pic['url'].toString());
        }
      }
    }

    final List<dynamic>? listaDescripciones = json['description'];
    final Map<String, dynamic>? primeraDescripcion =
        (listaDescripciones != null && listaDescripciones.isNotEmpty)
        ? listaDescripciones[0] as Map<String, dynamic>
        : null;
    final int? descId = primeraDescripcion != null ? primeraDescripcion['id'] as int? : null;

    return Monumento(
      id: json['id']?.toString(),
      nombre: json['name'] ?? '',
      categoria: json['tag'] != null ? json['tag']['id'].toString() : '1',
      accesible: json['accessibility'] ?? false,
      activo: json['isActive'] ?? true,
      latitud: lat,
      longitud: lon,
      imagenUrl: firstImage,
      imagenesUrls: allImages,
      audioUrl: primerAudio != null ? primerAudio['url'] : null,
      likes: json['NLikes'] ?? 0,
      paraNinos: primerAudio != null ? (primerAudio['kids'] ?? false) : false,
      idioma: primerAudio != null ? (primerAudio['language'] ?? 'es') : 'es',
      sinopsis: primeraDescripcion != null ? (primeraDescripcion['complete'] ?? false) : false,
      descripcionContenido: primeraDescripcion != null ? (primeraDescripcion['contenido'] ?? '') : '',
      descripcionNombre: primeraDescripcion != null ? (primeraDescripcion['name'] ?? '') : '',
      pictureId: picId,
      audioId: audId,
      descripcionId: descId,
    );
  }
}
