import 'dart:convert';

class Produtor {
  final int id;
  final String nome;
  final String email;
  final String municipio;
  final String regiao;
  final String papel;

  const Produtor({
    required this.id,
    required this.nome,
    required this.email,
    this.municipio = '',
    this.regiao = '',
    this.papel = 'PRODUTOR',
  });

  bool get isAdmin => papel == 'ADMIN';

  factory Produtor.fromJson(Map<String, dynamic> j) => Produtor(
        id: (j['id'] as num).toInt(),
        nome: j['nome'] as String,
        email: j['email'] as String,
        municipio: (j['municipio'] as String?) ?? '',
        regiao: (j['regiao'] as String?) ?? '',
        papel: (j['papel'] as String?) ?? 'PRODUTOR',
      );

  factory Produtor.fromJsonString(String s) =>
      Produtor.fromJson(jsonDecode(s) as Map<String, dynamic>);

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'email': email,
        'municipio': municipio,
        'regiao': regiao,
        'papel': papel,
      };

  String toJsonString() => jsonEncode(toJson());
}
