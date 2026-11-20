class ApiException implements Exception {
  final String mensagem;
  final int? status;

  final bool semRede;

  ApiException(this.mensagem, {this.status, this.semRede = false});

  @override
  String toString() => mensagem;
}
