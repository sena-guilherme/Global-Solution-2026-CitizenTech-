enum Severidade {
  critico('Crítico'),
  moderado('Moderado'),
  normal('Normal');

  const Severidade(this.rotulo);
  final String rotulo;

  String get api => name.toUpperCase();

  static Severidade fromApi(String? v) => Severidade.values
      .firstWhere((s) => s.api == v, orElse: () => Severidade.normal);
}

enum TipoAlerta {
  umidade('Umidade', '💧'),
  clima('Clima', '🌦️'),
  irrigacao('Irrigação', '🚿');

  const TipoAlerta(this.rotulo, this.emoji);
  final String rotulo;
  final String emoji;

  String get api => name.toUpperCase();

  static TipoAlerta fromApi(String? v) => TipoAlerta.values
      .firstWhere((t) => t.api == v, orElse: () => TipoAlerta.umidade);
}

class Alerta {
  final int id;
  final int? culturaId;
  final String culturaNome;
  final String areaNome;
  final TipoAlerta tipo;
  final Severidade severidade;
  final String mensagem;
  final String? recomendacao;
  final DateTime dataHora;
  bool lido;

  Alerta({
    required this.id,
    this.culturaId,
    this.culturaNome = '',
    this.areaNome = '',
    required this.tipo,
    required this.severidade,
    required this.mensagem,
    this.recomendacao,
    required this.dataHora,
    this.lido = false,
  });

  bool get envolveChuva =>
      tipo == TipoAlerta.clima && mensagem.toLowerCase().contains('chuva');

  factory Alerta.fromJson(Map<String, dynamic> j) => Alerta(
        id: (j['id'] as num).toInt(),
        culturaId: (j['culturaId'] as num?)?.toInt(),
        culturaNome: (j['culturaNome'] as String?) ?? '',
        areaNome: (j['areaNome'] as String?) ?? '',
        tipo: TipoAlerta.fromApi(j['tipo'] as String?),
        severidade: Severidade.fromApi(j['severidade'] as String?),
        mensagem: j['mensagem'] as String,
        recomendacao: j['recomendacao'] as String?,
        dataHora: DateTime.parse(j['dataGeracao'] as String),
        lido: (j['lido'] as bool?) ?? false,
      );

  String? get titulo => null;
}
