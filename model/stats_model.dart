class StatsModel {
  final int totalUsuarios;
  final int peticionesIA;
  final int rutasActivas;
  final List<MonumentStat> monumentosPopulares;

  StatsModel({
    required this.totalUsuarios,
    required this.peticionesIA,
    required this.rutasActivas,
    required this.monumentosPopulares,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    var monumentosList = json['monumentosPopulares'] as List? ?? [];
    List<MonumentStat> popular = monumentosList
        .map((m) => MonumentStat.fromJson(m))
        .toList();

    return StatsModel(
      totalUsuarios: json['totalUsuarios'] ?? 0,
      peticionesIA: json['consultasIA'] ?? 0,
      rutasActivas: json['rutasActivas'] ?? 0,
      monumentosPopulares: popular,
    );
  }
}

class MonumentStat {
  final String id;
  final String nombre;
  final String visitas;
  final String porcentaje;

  MonumentStat({
    required this.id,
    required this.nombre,
    required this.visitas,
    required this.porcentaje,
  });

  factory MonumentStat.fromJson(Map<String, dynamic> json) {
    return MonumentStat(
      id: json['id'] ?? '00',
      nombre: json['name'] ?? 'Desconocido',
      visitas: (json['NLikes'] ?? 0).toString(),
      porcentaje: '${json['NLikes'] ?? 0} likes',
    );
  }
}

class IaStat {
  final String name;
  final int count;

  IaStat({required this.name, required this.count});

  factory IaStat.fromJson(Map<String, dynamic> json) =>
      IaStat(name: json["nameCount"], count: json["count"] ?? 0);
}

class DescargaStat {
  final String nombrePlataforma;
  final int totalDownloads;

  DescargaStat({required this.nombrePlataforma, required this.totalDownloads});

  factory DescargaStat.fromJson(Map<String, dynamic> json) => DescargaStat(
    nombrePlataforma: json["name"],
    totalDownloads: json["totalDownloads"] ?? 0,
  );
}
