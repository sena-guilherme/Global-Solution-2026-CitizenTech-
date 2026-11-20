enum TipoCultura {
  hortalica('Hortaliça'),
  fruta('Fruta');

  const TipoCultura(this.rotulo);
  final String rotulo;

  String get api => name.toUpperCase();

  static TipoCultura fromApi(String? v) => TipoCultura.values
    .firstWhere((t) => t.api == v, orElse: () => TipoCultura.hortalica);
}

enum Estagio {
  germinacao('Germinação'),
  crescimento('Crescimento'),
  floracao('Floração'),
  colheita('Colheita');

  const Estagio(this.rotulo);
  final String rotulo;

  String get api => name.toUpperCase();

  static Estagio fromApi(String? v) => Estagio.values
      .firstWhere((e) => e.api == v, orElse: () => Estagio.crescimento);
}

class Cultura {
  final int? id;
  final int? areaId;
  final TipoCultura tipo;
  final String nome;
  final DateTime dataPlantio;
  final Estagio estagio;

  const Cultura({
    this.id,
    this.areaId,
    required this.tipo,
    required this.nome,
    required this.dataPlantio,
    required this.estagio,
  });

  int get diaDoCiclo {
    final hoje = DateTime.now();
    final dias = DateTime(hoje.year, hoje.month, hoje.day)
        .difference(DateTime(dataPlantio.year, dataPlantio.month, dataPlantio.day))
        .inDays;
    return dias < 0 ? 1 : dias + 1;
  }

  factory Cultura.fromJson(Map<String, dynamic> j) => Cultura(
        id: (j['id'] as num?)?.toInt(),
        areaId: (j['areaId'] as num?)?.toInt(),
        tipo: TipoCultura.fromApi(j['tipo'] as String?),
        nome: j['nome'] as String,
        dataPlantio: DateTime.parse(j['dataPlantio'] as String),
        estagio: Estagio.fromApi(j['estagio'] as String?),
      );

  Map<String, dynamic> toJson() => {
        'tipo': tipo.api,
        'nome': nome,
        'dataPlantio': _iso(dataPlantio),
        'estagio': estagio.api,
      };

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
