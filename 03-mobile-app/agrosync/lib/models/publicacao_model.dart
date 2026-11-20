import '../utils/imagens.dart';

class Publicacao {
  final int id;
  final int autorId;
  final String autor;
  final String cultura;
  final String regiao;
  final String texto;
  final String? imagemUrl;
  final String? imagemLocal;
  final SlotImagem? imagemSlot;
  final DateTime dataHora;
  int confirmacoes;

  bool confirmado;

  Publicacao({
    required this.id,
    required this.autorId,
    required this.autor,
    required this.cultura,
    required this.regiao,
    required this.texto,
    this.imagemUrl,
    this.imagemLocal,
    this.imagemSlot,
    required this.dataHora,
    this.confirmacoes = 0,
    this.confirmado = false,
  });

  factory Publicacao.fromJson(Map<String, dynamic> j) => Publicacao(
        id: (j['id'] as num).toInt(),
        autorId: (j['autorId'] as num).toInt(),
        autor: j['autor'] as String,
        cultura: (j['cultura'] as String?) ?? '',
        regiao: j['regiao'] as String,
        texto: j['texto'] as String,
        imagemUrl: j['imagemUrl'] as String?,
        dataHora: DateTime.parse(j['dataHora'] as String),
        confirmacoes: (j['confirmacoes'] as num?)?.toInt() ?? 0,
      );
}
