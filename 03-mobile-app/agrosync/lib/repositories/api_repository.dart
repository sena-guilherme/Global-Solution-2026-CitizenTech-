import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:agrosync/models/alerta_model.dart';
import 'package:agrosync/models/area_model.dart';
import 'package:agrosync/models/produtor_model.dart';
import 'package:agrosync/models/publicacao_model.dart';
import 'package:agrosync/repositories/api_exception.dart';
import 'package:agrosync/repositories/demo_data.dart';
import 'package:agrosync/repositories/local_storage.dart';

export 'package:agrosync/repositories/api_exception.dart';

class PaginaPublicacoes {
  final List<Publicacao> itens;
  final bool ultima;
  const PaginaPublicacoes(this.itens, this.ultima);
}

class ApiRepository {
  ApiRepository._();
  static final ApiRepository instance = ApiRepository._();

  static final ValueNotifier<bool> offline = ValueNotifier<bool>(false);

  String baseUrl = LocalStorage.urlPadrao;
  String? _token;
  Produtor? usuario;
  bool demo = false;

  bool get logado => demo || _token != null;

  void init() {
    final s = LocalStorage.instance;
    baseUrl = s.apiUrl;
    _token = s.token;
    usuario = s.usuario;
    demo = s.demo;
    if (demo) usuario ??= DemoData.usuario;
  }

  Future<void> definirUrl(String url) async {
    baseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    await LocalStorage.instance.salvarApiUrl(baseUrl);
  }

  Future<Produtor> login(String email, String senha) async {
    final json = await _send('POST', '/api/auth/login',
        body: {'email': email, 'senha': senha}, auth: false);
    return _guardarSessao(json as Map<String, dynamic>);
  }

  Future<Produtor> registrar({
    required String nome,
    required String email,
    required String senha,
    required String municipio,
    required String regiao,
  }) async {
    final json = await _send('POST', '/api/auth/register',
        body: {
          'nome': nome,
          'email': email,
          'senha': senha,
          'municipio': municipio,
          'regiao': regiao,
        },
        auth: false);
    return _guardarSessao(json as Map<String, dynamic>);
  }

  Future<Produtor> _guardarSessao(Map<String, dynamic> json) async {
    _token = json['token'] as String;
    usuario = Produtor.fromJson(json['usuario'] as Map<String, dynamic>);
    demo = false;
    await LocalStorage.instance
        .salvarSessao(token: _token, usuario: usuario!, demo: false);
    return usuario!;
  }

  Future<void> entrarModoDemo() async {
    demo = true;
    _token = null;
    usuario = DemoData.usuario;
    await LocalStorage.instance
        .salvarSessao(token: null, usuario: usuario!, demo: true);
  }

  Future<void> sair() async {
    _token = null;
    usuario = null;
    demo = false;
    offline.value = false;
    await LocalStorage.instance.limparSessao();
  }

  Future<List<Area>> listarAreas() async {
    if (demo) return DemoData.areas();
    final json = await _getComCache('/api/areas',
        query: {'size': '50', 'sort': 'nome,asc'});
    return _conteudo(json).map(Area.fromJson).toList();
  }

  Future<Area> buscarArea(int id) async {
    if (demo) {
      return DemoData.areas().firstWhere((a) => a.id == id,
          orElse: () => throw ApiException('Área não encontrada.', status: 404));
    }
    final json = await _getComCache('/api/areas/$id');
    return Area.fromJson(json as Map<String, dynamic>);
  }

  Future<Area> salvarArea(Area a) async {
    if (demo) return DemoData.salvarArea(a);
    final json = a.id == null
        ? await _send('POST', '/api/areas', body: a.toJson())
        : await _send('PUT', '/api/areas/${a.id}', body: a.toJson());
    return Area.fromJson(json as Map<String, dynamic>);
  }

  Future<void> excluirArea(int id) async {
    if (demo) return DemoData.excluirArea(id);
    await _send('DELETE', '/api/areas/$id');
  }

  Future<LeituraRegistrada> registrarLeitura(int areaId, double umidade) async {
    if (demo) return DemoData.registrarLeitura(areaId, umidade);
    final json = await _send('POST', '/api/areas/$areaId/leituras',
        body: {'valorUmidade': umidade, 'origem': 'MANUAL'});
    return LeituraRegistrada.fromJson(json as Map<String, dynamic>);
  }

  Future<List<LeituraSolo>> listarLeituras(int areaId) async {
    if (demo) return DemoData.leituras(areaId);
    final json =
        await _getComCache('/api/areas/$areaId/leituras', query: {'size': '20'});
    return _conteudo(json).map(LeituraSolo.fromJson).toList();
  }

  Future<Alerta> irrigar(int areaId) async {
    if (demo) return DemoData.irrigar(areaId);
    final json = await _send('POST', '/api/areas/$areaId/irrigacoes');
    return Alerta.fromJson(json as Map<String, dynamic>);
  }

  Future<RelatorioProdutor> relatorio() async {
    if (demo) return DemoData.relatorio();
    final json = await _getComCache('/api/relatorio');
    return RelatorioProdutor.fromJson(json as Map<String, dynamic>);
  }

  Future<List<Alerta>> listarAlertas({TipoAlerta? tipo, Severidade? severidade}) async {
    if (demo) return DemoData.alertas(tipo: tipo, severidade: severidade);
    final json = await _getComCache('/api/alertas', query: {
      'size': '50',
      if (tipo != null) 'tipo': tipo.api,
      if (severidade != null) 'severidade': severidade.api,
    });
    return _conteudo(json).map(Alerta.fromJson).toList();
  }

  Future<void> marcarAlertaLido(int id) async {
    if (demo) return DemoData.marcarLido(id);
    await _send('PATCH', '/api/alertas/$id/lido');
  }

  Future<PaginaPublicacoes> listarPublicacoes({
    String? regiao,
    String? busca,
    int pagina = 0,
  }) async {
    if (demo) {
      return PaginaPublicacoes(
          _marcarConfirmadas(DemoData.publicacoes(regiao: regiao, busca: busca)), true);
    }
    final json = await _getComCache('/api/publicacoes', query: {
      'page': '$pagina',
      'size': '10',
      if (regiao != null && regiao.trim().isNotEmpty) 'regiao': regiao.trim(),
      if (busca != null && busca.trim().isNotEmpty) 'busca': busca.trim(),
    }) as Map<String, dynamic>;
    final itens = _marcarConfirmadas(_conteudo(json).map(Publicacao.fromJson).toList());
    final info = json['page'] as Map<String, dynamic>?;
    final ultima = info == null
        ? true
        : ((info['number'] as num).toInt() + 1 >= (info['totalPages'] as num).toInt());
    return PaginaPublicacoes(itens, ultima);
  }

  List<Publicacao> _marcarConfirmadas(List<Publicacao> lista) {
    final confirmados = LocalStorage.instance.confirmados;
    for (final p in lista) {
      p.confirmado = confirmados.contains(p.id);
    }
    return lista;
  }

  Future<Publicacao> publicar({
    required String texto,
    required String cultura,
    required String regiao,
    File? imagem,
  }) async {
    if (demo) {
      return DemoData.publicar(
          texto: texto, cultura: cultura, regiao: regiao, imagem: imagem);
    }
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/publicacoes'))
      ..headers['Accept'] = 'application/json'
      ..fields['texto'] = texto
      ..fields['cultura'] = cultura
      ..fields['regiao'] = regiao;
    if (_token != null) req.headers['Authorization'] = 'Bearer $_token';
    if (imagem != null) {
      req.files.add(await http.MultipartFile.fromPath('imagem', imagem.path));
    }
    try {
      final stream = await req.send().timeout(const Duration(seconds: 30));
      final res = await http.Response.fromStream(stream);
      return Publicacao.fromJson(_tratar(res) as Map<String, dynamic>);
    } on TimeoutException {
      throw ApiException('O envio demorou demais. Tente novamente.', semRede: true);
    } on SocketException {
      throw ApiException('Sem conexão com o servidor.', semRede: true);
    } on http.ClientException {
      throw ApiException('Sem conexão com o servidor.', semRede: true);
    }
  }

  Future<Publicacao> confirmar(int id, {required bool confirmar}) async {
    final Publicacao p;
    if (demo) {
      p = DemoData.confirmar(id, confirmar);
    } else {
      final json = confirmar
          ? await _send('POST', '/api/publicacoes/$id/confirmar')
          : await _send('DELETE', '/api/publicacoes/$id/confirmar');
      p = Publicacao.fromJson(json as Map<String, dynamic>);
    }
    await LocalStorage.instance.salvarConfirmado(id, confirmar);
    p.confirmado = confirmar;
    return p;
  }

  Future<void> excluirPublicacao(int id) async {
    if (demo) return DemoData.excluirPublicacao(id);
    await _send('DELETE', '/api/publicacoes/$id');
  }

  Future<String> testarConexao() async {
    if (demo) return 'Modo demonstração: não há servidor para testar.';
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/status'))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) return 'Conectado com sucesso ao servidor.';
      return 'O servidor respondeu com o código ${res.statusCode}.';
    } on TimeoutException {
      return 'Sem resposta do servidor (tempo esgotado).';
    } on SocketException {
      return 'Não foi possível conectar. Confira o endereço e a rede.';
    } on http.ClientException {
      return 'Não foi possível conectar. Confira o endereço e a rede.';
    }
  }

  String urlImagem(String caminho) =>
    caminho.startsWith('http') ? caminho : '$baseUrl$caminho';

  List<Map<String, dynamic>> _conteudo(dynamic json) =>
    ((json as Map<String, dynamic>)['content'] as List)
      .cast<Map<String, dynamic>>();

  Future<dynamic> _send(
    String metodo,
    String caminho, {
    Map<String, String>? query,
    Object? body,
    bool auth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$caminho')
        .replace(queryParameters: (query == null || query.isEmpty) ? null : query);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json; charset=utf-8',
      if (auth && _token != null) 'Authorization': 'Bearer $_token',
    };
    final corpo = body == null ? null : jsonEncode(body);

    try {
      final Future<http.Response> req = switch (metodo) {
        'GET' => http.get(uri, headers: headers),
        'POST' => http.post(uri, headers: headers, body: corpo),
        'PUT' => http.put(uri, headers: headers, body: corpo),
        'PATCH' => http.patch(uri, headers: headers, body: corpo),
        'DELETE' => http.delete(uri, headers: headers),
        _ => throw ArgumentError('Método HTTP inválido: $metodo'),
      };
      final res = await req.timeout(const Duration(seconds: 12));
      return _tratar(res);
    } on TimeoutException {
      throw ApiException('O servidor demorou para responder.', semRede: true);
    } on SocketException {
      throw ApiException('Sem conexão com o servidor.', semRede: true);
    } on http.ClientException {
      throw ApiException('Sem conexão com o servidor.', semRede: true);
    }
  }

  dynamic _tratar(http.Response res) {
    final texto = utf8.decode(res.bodyBytes);
    dynamic corpo;
    if (texto.isNotEmpty) {
      try {
        corpo = jsonDecode(texto);
      } catch (_) {
        corpo = null;
      }
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return corpo;

    if (res.statusCode == 401 && _token != null) {
      unawaited(sair());
      throw ApiException('Sessão expirada. Entre novamente.', status: 401);
    }
    throw ApiException(_mensagemErro(corpo, res.statusCode), status: res.statusCode);
  }

  String _mensagemErro(dynamic corpo, int status) {
    if (corpo is Map<String, dynamic>) {
      final campos = corpo['fieldErrors'];
      if (campos is List && campos.isNotEmpty) {
        return campos
            .map((c) => '${(c as Map)['campo']}: ${c['mensagem']}')
            .join('\n');
      }
      final msg = corpo['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    switch (status) {
      case 401:
        return 'E-mail ou senha inválidos.';
      case 403:
        return 'Você não tem permissão para esta ação.';
      case 404:
        return 'Item não encontrado.';
      default:
        return status >= 500
            ? 'Erro no servidor. Tente novamente em instantes.'
            : 'Não foi possível concluir a operação ($status).';
    }
  }

  Future<dynamic> _getComCache(String caminho, {Map<String, String>? query}) async {
    final chave = 'cache:$caminho?${query ?? {}}';
    try {
      final json = await _send('GET', caminho, query: query);
      offline.value = false;
      await LocalStorage.instance.salvarCache(chave, jsonEncode(json));
      return json;
    } on ApiException catch (e) {
      if (!e.semRede) rethrow;
      final salvo = LocalStorage.instance.lerCache(chave);
      if (salvo == null) rethrow;
      offline.value = true;
      return jsonDecode(salvo);
    }
  }
}
