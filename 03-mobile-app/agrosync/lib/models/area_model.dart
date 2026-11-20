import 'alerta_model.dart';
import 'cultura_model.dart';

enum ClassificacaoUmidade {
  critico('Crítico', 'Irrigação urgente. Risco alto de perda da safra.'),
  moderado('Moderado', 'Irrigar nas próximas 24 horas.'),
  normal('Normal', 'Umidade adequada. Manter monitoramento.'),
  excesso('Excesso', 'Solo encharcado. Suspender irrigação.');

  const ClassificacaoUmidade(this.rotulo, this.recomendacao);
  final String rotulo;
  final String recomendacao;

  static ClassificacaoUmidade de(double umidade) {
    if (umidade < 20) return ClassificacaoUmidade.critico;
    if (umidade < 35) return ClassificacaoUmidade.moderado;
    if (umidade <= 70) return ClassificacaoUmidade.normal;
    return ClassificacaoUmidade.excesso;
  }
}

class LeituraSolo {
  final int id;
  final double valorUmidade;
  final DateTime dataHora;
  final String origem;
  final String? idDispositivo; 

  const LeituraSolo({
    required this.id,
    required this.valorUmidade,
    required this.dataHora,
    required this.origem,
    this.idDispositivo,
  });

  ClassificacaoUmidade get classificacao => ClassificacaoUmidade.de(valorUmidade);

  String get origemRotulo {
    if (origem != 'SENSOR') return 'Manual';
    final disp = idDispositivo?.trim() ?? '';
    return disp.isEmpty ? 'Sensor' : 'Sensor $disp';
  }

  factory LeituraSolo.fromJson(Map<String, dynamic> j) => LeituraSolo(
        id: (j['id'] as num).toInt(),
        valorUmidade: (j['valorUmidade'] as num).toDouble(),
        dataHora: DateTime.parse(j['dataHora'] as String),
        origem: j['origem'] as String,
        idDispositivo: j['idDispositivo'] as String?,
      );
}

class Area {
  final int? id;
  final int? produtorId;
  final String nome;
  final double tamanhoHa;
  final double latitude;
  final double longitude;
  final Cultura? cultura;
  final LeituraSolo? ultimaLeitura;
  final String? recomendacao;

  const Area({
    this.id,
    this.produtorId,
    required this.nome,
    required this.tamanhoHa,
    required this.latitude,
    required this.longitude,
    this.cultura,
    this.ultimaLeitura,
    this.recomendacao,
  });

  factory Area.fromJson(Map<String, dynamic> j) => Area(
        id: (j['id'] as num?)?.toInt(),
        produtorId: (j['produtorId'] as num?)?.toInt(),
        nome: j['nome'] as String,
        tamanhoHa: (j['tamanhoHa'] as num).toDouble(),
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
        cultura: j['cultura'] == null
            ? null
            : Cultura.fromJson(j['cultura'] as Map<String, dynamic>),
        ultimaLeitura: j['ultimaLeitura'] == null
            ? null
            : LeituraSolo.fromJson(j['ultimaLeitura'] as Map<String, dynamic>),
        recomendacao: j['recomendacao'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'tamanhoHa': tamanhoHa,
        'latitude': latitude,
        'longitude': longitude,
        if (cultura != null) 'cultura': cultura!.toJson(),
      };
}

class LeituraRegistrada {
  final LeituraSolo leitura;
  final Alerta alerta;
  const LeituraRegistrada(this.leitura, this.alerta);

  factory LeituraRegistrada.fromJson(Map<String, dynamic> j) => LeituraRegistrada(
        LeituraSolo.fromJson(j['leitura'] as Map<String, dynamic>),
        Alerta.fromJson(j['alerta'] as Map<String, dynamic>),
      );
}

class RelatorioProdutor {
  final String produtor;
  final String municipio;
  final int qtdAreas;
  final int totalAlertas;
  final int alertasCriticos;

  const RelatorioProdutor({
    required this.produtor,
    required this.municipio,
    required this.qtdAreas,
    required this.totalAlertas,
    required this.alertasCriticos,
  });

  factory RelatorioProdutor.fromJson(Map<String, dynamic> j) => RelatorioProdutor(
        produtor: j['produtor'] as String,
        municipio: (j['municipio'] as String?) ?? '',
        qtdAreas: (j['qtdAreas'] as num).toInt(),
        totalAlertas: (j['totalAlertas'] as num).toInt(),
        alertasCriticos: (j['alertasCriticos'] as num).toInt(),
      );
}
