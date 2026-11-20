import 'dart:io';

import 'package:agrosync/models/alerta_model.dart';
import 'package:agrosync/models/area_model.dart';
import 'package:agrosync/models/cultura_model.dart';
import 'package:agrosync/models/produtor_model.dart';
import 'package:agrosync/models/publicacao_model.dart';
import 'package:agrosync/utils/imagens.dart';
import 'package:agrosync/repositories/api_exception.dart';

class DemoData {
  static const Produtor usuario = Produtor(
      id: 1,
      nome: 'Produtor Demo',
      email: 'demo@agrosync.com',
      municipio: 'Piedade',
      regiao: 'Sorocaba');

  static int _seq = 1000;
  static int _proximo() => ++_seq;

  static DateTime _atras({int dias = 0, int horas = 0}) =>
      DateTime.now().subtract(Duration(days: dias, hours: horas));

  static final List<Area> _areas = [
    Area(
      id: 1,
      produtorId: 1,
      nome: 'Horta Principal',
      tamanhoHa: 1.5,
      latitude: -23.7119,
      longitude: -47.4278,
      cultura: Cultura(
        id: 1,
        areaId: 1,
        tipo: TipoCultura.hortalica,
        nome: 'Alface Crespa',
        dataPlantio: _atras(dias: 21),
        estagio: Estagio.crescimento,
      ),
    ),
    Area(
      id: 2,
      produtorId: 1,
      nome: 'Pomar de Morango',
      tamanhoHa: 3.2,
      latitude: -23.6564,
      longitude: -47.2225,
      cultura: Cultura(
        id: 2,
        areaId: 2,
        tipo: TipoCultura.fruta,
        nome: 'Morango',
        dataPlantio: _atras(dias: 35),
        estagio: Estagio.floracao,
      ),
    ),
  ];

  static LeituraSolo _leitura(int id, double u, String origem, String? disp, int horas) =>
      LeituraSolo(
        id: id,
        valorUmidade: u,
        dataHora: _atras(horas: horas),
        origem: origem,
        idDispositivo: disp,
      );

  static final Map<int, List<LeituraSolo>> _leituras = {
    1: [
      _leitura(1, 68, 'SENSOR', 'ARD-001', 2),
      _leitura(2, 45, 'SENSOR', 'ARD-001', 14),
      _leitura(3, 22, 'SENSOR', 'ARD-001', 50),
    ],
    2: [
      _leitura(4, 18.5, 'SENSOR', 'ARD-002', 3),
      _leitura(5, 55, 'MANUAL', null, 20),
    ],
  };

  static final List<Alerta> _alertas = [
    Alerta(
      id: 1,
      culturaId: 2,
      culturaNome: 'Morango',
      areaNome: 'Pomar de Morango',
      tipo: TipoAlerta.umidade,
      severidade: Severidade.critico,
      mensagem: 'Umidade do solo em 18.5% - irrigacao urgente para Morango',
      recomendacao: ClassificacaoUmidade.critico.recomendacao,
      dataHora: _atras(horas: 3),
    ),
    Alerta(
      id: 2,
      culturaId: 1,
      culturaNome: 'Alface Crespa',
      areaNome: 'Horta Principal',
      tipo: TipoAlerta.clima,
      severidade: Severidade.moderado,
      mensagem: 'Chuva forte prevista para amanha - 45 mm na regiao',
      recomendacao: 'Planeje a proteção da lavoura para as próximas horas.',
      dataHora: _atras(horas: 5),
    ),
    Alerta(
      id: 3,
      culturaId: 1,
      culturaNome: 'Alface Crespa',
      areaNome: 'Horta Principal',
      tipo: TipoAlerta.umidade,
      severidade: Severidade.normal,
      mensagem: 'Umidade do solo em 68% - dentro da faixa ideal para Alface Crespa',
      recomendacao: ClassificacaoUmidade.normal.recomendacao,
      dataHora: _atras(horas: 2),
      lido: true,
    ),
  ];

  static final List<Publicacao> _publicacoes = [
    Publicacao(
      id: 1,
      autorId: 10,
      autor: 'Dona Maria',
      cultura: 'Alface',
      regiao: 'Piedade',
      texto:
          'Cobrir as mudas com sombrite de 50% salvou minha producao na onda de calor dessa semana.',
      imagemSlot: Imagens.relatoDemo1,
      dataHora: _atras(dias: 1),
      confirmacoes: 14,
    ),
    Publicacao(
      id: 2,
      autorId: 11,
      autor: 'Carlos H.',
      cultura: 'Morango',
      regiao: 'Ibiuna',
      texto:
          'Cuidado com excesso de irrigacao noturna apos chuvas rapidas. Evitou fungo por aqui.',
      imagemSlot: Imagens.relatoDemo2,
      dataHora: _atras(dias: 2),
      confirmacoes: 22,
    ),
  ];

  static Area _comLeitura(Area a) {
    final l = _leituras[a.id]?.isNotEmpty == true ? _leituras[a.id]!.first : null;
    return Area(
      id: a.id,
      produtorId: a.produtorId,
      nome: a.nome,
      tamanhoHa: a.tamanhoHa,
      latitude: a.latitude,
      longitude: a.longitude,
      cultura: a.cultura,
      ultimaLeitura: l,
      recomendacao: l?.classificacao.recomendacao,
    );
  }

  static List<Area> areas() => _areas.map(_comLeitura).toList();

  static Area salvarArea(Area nova) {
    if (nova.id == null) {
      final id = _proximo();
      final cultura = nova.cultura == null
          ? null
          : Cultura(
              id: _proximo(),
              areaId: id,
              tipo: nova.cultura!.tipo,
              nome: nova.cultura!.nome,
              dataPlantio: nova.cultura!.dataPlantio,
              estagio: nova.cultura!.estagio);
      final criada = Area(
          id: id,
          produtorId: usuario.id,
          nome: nova.nome,
          tamanhoHa: nova.tamanhoHa,
          latitude: nova.latitude,
          longitude: nova.longitude,
          cultura: cultura);
      _areas.add(criada);
      _leituras[id] = [];
      return _comLeitura(criada);
    }
    final i = _areas.indexWhere((a) => a.id == nova.id);
    if (i < 0) throw ApiException('Área não encontrada.', status: 404);
    final atual = _areas[i];
    final cultura = nova.cultura == null
        ? atual.cultura
        : Cultura(
            id: atual.cultura?.id ?? _proximo(),
            areaId: atual.id,
            tipo: nova.cultura!.tipo,
            nome: nova.cultura!.nome,
            dataPlantio: nova.cultura!.dataPlantio,
            estagio: nova.cultura!.estagio);
    _areas[i] = Area(
        id: atual.id,
        produtorId: atual.produtorId,
        nome: nova.nome,
        tamanhoHa: nova.tamanhoHa,
        latitude: nova.latitude,
        longitude: nova.longitude,
        cultura: cultura);
    return _comLeitura(_areas[i]);
  }

  static void excluirArea(int id) {
    final area = _areas.firstWhere((a) => a.id == id,
        orElse: () => throw ApiException('Área não encontrada.', status: 404));
    _alertas.removeWhere((a) => a.culturaId == area.cultura?.id);
    _areas.removeWhere((a) => a.id == id);
    _leituras.remove(id);
  }

  static List<LeituraSolo> leituras(int areaId) => List.of(_leituras[areaId] ?? []);

  static LeituraRegistrada registrarLeitura(int areaId, double umidade) {
    final area = _areas.firstWhere((a) => a.id == areaId,
        orElse: () => throw ApiException('Área não encontrada.', status: 404));
    final cultura = area.cultura;
    if (cultura == null) {
      throw ApiException('A área $areaId não possui cultura cadastrada.', status: 409);
    }
    final leitura = LeituraSolo(
        id: _proximo(), valorUmidade: umidade, dataHora: DateTime.now(), origem: 'MANUAL');
    _leituras.putIfAbsent(areaId, () => []).insert(0, leitura);

    final classe = ClassificacaoUmidade.de(umidade);
    final valor = umidade == umidade.roundToDouble()
        ? umidade.round().toString()
        : umidade.toString();
    final base = 'Umidade do solo em $valor% - ';
    final mensagem = switch (classe) {
      ClassificacaoUmidade.critico => '${base}irrigacao urgente para ${cultura.nome}',
      ClassificacaoUmidade.moderado => '${base}irrigar nas proximas 24h para ${cultura.nome}',
      ClassificacaoUmidade.excesso =>
        '${base}solo encharcado, suspender irrigacao para ${cultura.nome}',
      ClassificacaoUmidade.normal => '${base}dentro da faixa ideal para ${cultura.nome}',
    };
    final alerta = Alerta(
      id: _proximo(),
      culturaId: cultura.id,
      culturaNome: cultura.nome,
      areaNome: area.nome,
      tipo: TipoAlerta.umidade,
      severidade: switch (classe) {
        ClassificacaoUmidade.critico => Severidade.critico,
        ClassificacaoUmidade.moderado => Severidade.moderado,
        _ => Severidade.normal,
      },
      mensagem: mensagem,
      recomendacao: classe.recomendacao,
      dataHora: DateTime.now(),
    );
    _alertas.insert(0, alerta);
    return LeituraRegistrada(leitura, alerta);
  }

  static Alerta irrigar(int areaId) {
    final area = _areas.firstWhere((a) => a.id == areaId,
        orElse: () => throw ApiException('Área não encontrada.', status: 404));
    final cultura = area.cultura;
    if (cultura == null) {
      throw ApiException('A área $areaId não possui cultura cadastrada.', status: 409);
    }
    final alerta = Alerta(
      id: _proximo(),
      culturaId: cultura.id,
      culturaNome: cultura.nome,
      areaNome: area.nome,
      tipo: TipoAlerta.irrigacao,
      severidade: Severidade.normal,
      mensagem: 'Irrigacao manual registrada na area ${area.nome} (${cultura.nome})',
      recomendacao: 'Irrigação registrada. Acompanhe a umidade nas próximas leituras.',
      dataHora: DateTime.now(),
    );
    _alertas.insert(0, alerta);
    return alerta;
  }

  static RelatorioProdutor relatorio() {
    final minhas = _areas.map((a) => a.cultura?.id).toSet();
    final meus = _alertas.where((a) => minhas.contains(a.culturaId)).toList();
    return RelatorioProdutor(
      produtor: usuario.nome,
      municipio: usuario.municipio,
      qtdAreas: _areas.length,
      totalAlertas: meus.length,
      alertasCriticos: meus.where((a) => a.severidade == Severidade.critico).length,
    );
  }

  static List<Alerta> alertas({TipoAlerta? tipo, Severidade? severidade}) {
    final lista = _alertas.where((a) {
      if (tipo != null && a.tipo != tipo) return false;
      if (severidade != null && a.severidade != severidade) return false;
      return true;
    }).toList();
    lista.sort((a, b) => b.dataHora.compareTo(a.dataHora));
    return lista;
  }

  static void marcarLido(int id) {
    for (final a in _alertas) {
      if (a.id == id) a.lido = true;
    }
  }

  static List<Publicacao> publicacoes({String? regiao, String? busca}) {
    final termo = busca?.trim().toLowerCase() ?? '';
    final reg = regiao?.trim().toLowerCase() ?? '';
    final lista = _publicacoes.where((p) {
      if (reg.isNotEmpty && p.regiao.toLowerCase() != reg) return false;
      if (termo.isNotEmpty &&
          !p.texto.toLowerCase().contains(termo) &&
          !p.cultura.toLowerCase().contains(termo) &&
          !p.autor.toLowerCase().contains(termo) &&
          !p.regiao.toLowerCase().contains(termo)) {
        return false;
      }
      return true;
    }).toList();
    lista.sort((a, b) => b.dataHora.compareTo(a.dataHora));
    return lista;
  }

  static Publicacao publicar({
    required String texto,
    required String cultura,
    required String regiao,
    File? imagem,
  }) {
    final p = Publicacao(
      id: _proximo(),
      autorId: usuario.id,
      autor: usuario.nome,
      cultura: cultura,
      regiao: regiao,
      texto: texto,
      imagemLocal: imagem?.path,
      dataHora: DateTime.now(),
    );
    _publicacoes.insert(0, p);
    return p;
  }

  static Publicacao confirmar(int id, bool confirmar) {
    final p = _publicacoes.firstWhere((p) => p.id == id);
    p.confirmacoes = confirmar ? p.confirmacoes + 1 : (p.confirmacoes > 0 ? p.confirmacoes - 1 : 0);
    return p;
  }

  static void excluirPublicacao(int id) => _publicacoes.removeWhere((p) => p.id == id);
}
